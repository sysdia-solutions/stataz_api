defmodule StatazApi.AuthController.ActionDelete do
  use StatazApi.Web, :controller

  def execute(conn, params) do
    StatazApi.Auth.logout(conn, Repo, params["client_id"])
    |> send_resp(:no_content, "")
  end
end
