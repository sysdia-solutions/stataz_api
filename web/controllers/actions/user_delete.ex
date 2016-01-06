defmodule StatazApi.UserController.ActionDelete do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, username) do
    Repo.get_by(User, %{username: username})
    |> delete(conn, username)
  end

  defp delete(user = %User{}, conn, _username) do
    Repo.delete!(user)
    send_resp(conn, :no_content, "")
  end

  defp delete(nil, conn, username) do
    error = %StatazApi.Error.NotFound{resource: "User", id: username}
    put_status(conn, :not_found)
    |> render("show.json", error: error)
  end
end
