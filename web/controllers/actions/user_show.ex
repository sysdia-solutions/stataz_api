defmodule StatazApi.UserController.ActionShow do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn) do
    Repo.get(User, conn.assigns.current_user.id)
    |> response(conn)
  end

  defp response(user = %User{}, conn) do
    render(conn, "show.json", user: user)
  end

  defp response(nil, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end
end
