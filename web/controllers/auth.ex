defmodule StatazApi.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias StatazApi.Util.Time
  alias StatazApi.User
  alias StatazApi.AccessToken

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    username = Map.get(conn.params, "username")
    access_token = get_req_header(conn, "authorization")

    expire_tokens(repo)

    authenticate_user(repo, username, access_token)
    |> call_response(conn)
  end

  def login_with_username_and_password(repo, username, password) do
    user = repo.get_by(User, username: username)

    cond do
      user && checkpw(password, user.password_hash) ->
        login_response(user, repo)
      user ->
        {:error, :unauthorized}
      true ->
        {:error, :not_found}
    end
  end

  def logout(conn, repo) do
    if conn.assigns[:current_user] do
      {deleted, _} = delete_user_token(conn, repo, conn.assigns.current_user.id)
      if deleted > 0 do
        conn = assign(conn, :current_user, nil)
      end
    end
    conn
  end

  def show_token(conn, repo) do
    if conn.assigns[:current_user] do
      access_token = get_req_header(conn, "authorization")
      token = check_token(repo, conn.assigns.current_user.id, access_token)

      if token do
        {:ok, token}
      else
        {:error, :unauthorized}
      end
    else
      {:error, :unprocessable_entity}
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
    AccessToken.delete_for_user_id_and_token(user_id, access_token)
    |> repo.delete_all()
  end


  defp expire_tokens(repo) do
    Time.ecto_now()
    |> AccessToken.delete_all_expired()
    |> repo.delete_all()
  end

  defp authenticate_user(repo, username, access_token) do
    user = repo.get_by(User, username: username)

    cond do
      user && check_token(repo, user.id, access_token) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        {:error, :not_found}
    end
  end

  defp check_token(repo, user_id, token) do
    parsed_token = parse_token(token)

    access_token = AccessToken.get_by_user_id_and_token(user_id, parsed_token)
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

  defp login_response(user, repo) do
    case login(user, repo) do
      {:ok, access_token} -> {:ok, access_token}
      {:error, _changeset} -> {:error, :unprocessable_entity}
    end
  end

  defp login(user, repo) do
    AccessToken.changeset(%AccessToken{}, %{user_id: user.id, token: generate_token(), expires: generate_expiry()})
    |> repo.insert()
  end

  defp generate_token() do
    Ecto.UUID.generate
    |> String.replace("-", "")
  end

  defp generate_expiry() do
    Time.ecto_now()
    |> Time.ecto_shift(secs: Application.get_env(:stataz_api, :access_token_expires))
  end
end
