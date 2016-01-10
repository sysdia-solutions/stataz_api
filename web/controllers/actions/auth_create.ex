defmodule StatazApi.AuthController.ActionCreate do
  use StatazApi.Web, :controller

  def execute(conn, %{"username" => username, "password" => password}) do
    StatazApi.Auth.login_with_username_and_password(Repo, username, password)
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
