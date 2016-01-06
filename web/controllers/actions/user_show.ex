defmodule StatazApi.UserController.ActionShow do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, username) do
    Repo.get_by(User, %{username: username})
    |> response(conn, username)
  end

  defp response(user = %User{}, conn, _username) do
    render(conn, "show.json", user: user)
  end

  defp response(nil, conn, username) do
    error = %StatazApi.Error.NotFound{resource: "User", id: username}
    put_status(conn, :not_found)
    |> render(error: error)
  end
end
