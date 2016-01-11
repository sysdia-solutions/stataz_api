defmodule StatazApi.StatusController.ActionCreate do
  use StatazApi.Web, :controller
  alias StatazApi.Status

  def execute(conn, params) do
    Status.changeset(%Status{}, %{user_id: conn.assigns.current_user.id, description: params["description"]})
    |> Repo.insert()
    |> response(conn)
  end

  defp response({:ok, status}, conn) do
    conn
    |> put_status(:created)
    |> render("show.json", status: status)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end
end
