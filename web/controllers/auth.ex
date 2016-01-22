defmodule StatazApi.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias StatazApi.Util.Time
  alias StatazApi.User
  alias StatazApi.AccessToken
  alias StatazApi.RefreshToken

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    access_token = get_req_header(conn, "authorization")
    expire_tokens(repo)

    authenticate_token(repo, access_token)
    |> call_response(conn)
  end

  def login_with_username_and_password(repo, username, password, client_id) do
    user = repo.get_by(User, username: username)

    cond do
      user && checkpw(password, user.password_hash) ->
        login_response(user, repo, client_id)
      user ->
        {:error, :unauthorized}
      true ->
        {:error, :unauthorized}
    end
  end

  def login_with_refresh_token(repo, refresh_token, client_id) do
    token = RefreshToken.by_client_id_and_token(client_id, refresh_token)
            |> repo.all()
            |> List.first()

    case token do
      nil ->
        {:error, :unauthorized}
      _ ->
        repo.get(User, token.user_id)
        |> login_response(repo, client_id)
    end
  end

  def logout(conn, repo, client_id \\ "") do
    if conn.assigns[:current_user] do
      {deleted, _} = delete_user_token(conn, repo, conn.assigns.current_user.id)
      if deleted > 0 do
        delete_user_refresh_token(repo, conn.assigns.current_user.id, client_id)
        conn = assign(conn, :current_user, nil)
      end
    end
    conn
  end

  def purge_tokens(conn, repo) do
    if conn.assigns[:current_user] do
      AccessToken.by_user_id(conn.assigns.current_user.id)
      |> repo.delete_all()
      RefreshToken.by_user_id(conn.assigns.current_user.id)
      |> repo.delete_all()
    end
  end

  def get_token(conn, repo) do
    if conn.assigns[:current_user] do
      parsed_token = parse_token(get_req_header(conn, "authorization"))
      access_token = AccessToken.by_user_id_and_token(conn.assigns.current_user.id, parsed_token)
                     |> repo.one()
      if access_token do
        return_token = %{
          access_token: parsed_token,
          expires: access_token.expires,
          refresh_token: nil
        }
        {:ok, return_token}
      else
        {:error, :unauthorized}
      end
    else
      {:error, :unauthorized}
    end
  end

  defp call_response({:ok, user}, conn) do
    assign(conn, :current_user, user)
  end

  defp call_response({:error, status}, conn) do
    body = %{errors:
             %{ title: StatazApi.ErrorHelpers.translate_error(to_string(status)) }
           } |> Poison.Encoder.encode([])
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, body)
    |> halt()
  end

  defp delete_user_token(conn, repo, user_id) do
    access_token = parse_token(get_req_header(conn, "authorization"))
    AccessToken.by_user_id_and_token(user_id, access_token)
    |> repo.delete_all()
  end

  defp delete_user_refresh_token(repo, user_id, client_id) do
    if client_id != nil do
      RefreshToken.by_client_id_and_user_id(client_id, user_id)
      |> repo.delete_all()
    end
  end

  defp expire_tokens(repo) do
    Time.ecto_now()
    |> AccessToken.by_all_expired()
    |> repo.delete_all()
  end

  defp authenticate_token(repo, access_token) do
    if token = check_token(repo, access_token) do
      user = repo.get(User, token.user_id)
      {:ok, user}
    else
      {:error, :unauthorized}
    end
  end

  defp check_token(repo, token) do
    parsed_token = parse_token(token)

    access_token = AccessToken.by_token(parsed_token)
                   |> repo.one()

    if access_token do
      access_token = Map.put(access_token, :token, parsed_token)
    end

    access_token
  end

  defp parse_token(["Bearer " <> token]) do
    token
  end

  defp parse_token(_invalid) do
    ""
  end

  defp login_response(user, repo, client_id) do
    access_token = create_access_token(user, repo)
    refresh_token = create_refresh_token(user, repo, client_id)

    create_combined_token(access_token, refresh_token)
  end

  defp create_combined_token({:ok, access_token}, {:ok, refresh_token}) do
    build_combined_token(access_token.token, access_token.expires, refresh_token.token)
  end

  defp create_combined_token({:ok, access_token}, nil) do
    build_combined_token(access_token.token, access_token.expires, "")
  end

  defp create_combined_token(_bad_access_token, _bad_refresh_token) do
    {:error, :unprocessable_entity}
  end

  defp build_combined_token(access_token, expires, refresh_token) do
    combined_token = %{
                       access_token: access_token,
                       expires: expires,
                       refresh_token: refresh_token
                      }
    {:ok, combined_token}
  end

  defp create_access_token(user, repo) do
    AccessToken.changeset(%AccessToken{}, %{user_id: user.id, token: generate_token(user), expires: generate_expiry()})
    |> repo.insert()
  end

  defp create_refresh_token(user, repo, client_id) do
    params = %{user_id: user.id, client_id: client_id, token: generate_token(user)}
    case RefreshToken.changeset(%RefreshToken{}, params) |> repo.insert do
      {:ok, refresh_token} ->
        RefreshToken.by_client_id_excluding_id(client_id, refresh_token.id)
        |> repo.delete_all()
        {:ok, refresh_token}
      _ ->
        nil
    end
  end

  defp generate_token(user) do
    token = Ecto.UUID.generate
            |> String.replace("-", "")

    salt = :crypto.hash(:md5, user.username)
           |> Base.encode16

    :crypto.hash(:sha512, token <> salt)
    |> Base.encode16
  end

  defp generate_expiry() do
    Time.ecto_now()
    |> Time.ecto_shift(secs: Application.get_env(:stataz_api, :access_token_expires))
  end
end
