defmodule StatazApi.StatusController.ActionDelete do
  use StatazApi.Web, :controller
  alias StatazApi.Status

  def execute(conn, %{"id" => id}) do
    status = Repo.get(Status, id)
    Status.get_by_id_and_inactive(id)
    |> Repo.delete_all()
    |> response(conn, status)
  end

  defp response({0, _}, conn, nil) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end

  defp response({0, _}, conn, _status) do
    put_status(conn, :forbidden)
    |> render("show.json", error: :forbidden)
  end

  defp response({_rows, _}, conn, _status) do
    send_resp(conn, :no_content, "")
  end
end
