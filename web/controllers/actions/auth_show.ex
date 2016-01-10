defmodule StatazApi.AuthController.ActionShow do
  use StatazApi.Web, :controller

  def execute(conn) do
    StatazApi.Auth.show_token(conn, Repo)
    |> response(conn)
  end

  defp response({:ok, access_token}, conn) do
    conn
    |> put_status(:ok)
    |> render("show.json", access_token: access_token)
  end

  defp response({:error, status}, conn) do
    conn
    |> put_status(status)
    |> render("show.json", error: status)
  end
end
