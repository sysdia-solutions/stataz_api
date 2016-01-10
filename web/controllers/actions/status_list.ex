defmodule StatazApi.StatusController.ActionList do
  use StatazApi.Web, :controller
  alias StatazApi.Status

  def execute(conn) do
    Status.get_by_user_id(conn.assigns.current_user.id)
    |> Repo.all()
    |> response(conn)
  end

  defp response(status, conn) do
    conn
    |> put_status(:ok)
    |> render("list.json", status: status)
  end
end
