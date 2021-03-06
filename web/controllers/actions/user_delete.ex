defmodule StatazApi.UserController.ActionDelete do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn) do
    Repo.get(User, conn.assigns.current_user.id)
    |> delete(conn)
  end

  defp delete(user = %User{}, conn) do
    Repo.delete!(user)
    send_resp(conn, :no_content, "")
  end

  defp delete(nil, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end
end
