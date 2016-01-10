defmodule StatazApi.AuthController.ActionDelete do
  use StatazApi.Web, :controller

  def execute(conn) do
    StatazApi.Auth.logout(conn, Repo)
    |> send_resp(:no_content, "")
  end
end
