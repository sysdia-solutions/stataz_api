defmodule StatazApi.AuthController.ActionCreate do
  use StatazApi.Web, :controller

  def execute(conn, params) do
    case params["grant_type"] do
      "password" ->
        StatazApi.Auth.login_with_username_and_password(Repo, params["username"], params["password"], params["client_id"])
      "refresh_token" ->
        StatazApi.Auth.login_with_refresh_token(Repo, params["refresh_token"], params["client_id"])
      _ ->
        {:error, :unauthorized}
    end
    |> response(conn)
  end

  defp response({:ok, access_token}, conn) do
    conn
    |> put_status(:created)
    |> render("show.json", access_token: access_token)
  end

  defp response({:error, status}, conn) do
    conn
    |> put_status(status)
    |> render("show.json", error: status)
  end
end
