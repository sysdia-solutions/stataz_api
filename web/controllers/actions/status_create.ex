defmodule StatazApi.StatusController.ActionCreate do
  use StatazApi.Web, :controller
  alias StatazApi.Status

  def execute(conn, params) do
    build(conn.assigns.current_user.id, params["description"])
    |> response(conn)
  end

  def build(user_id, description) do
    Status.changeset(%Status{}, %{user_id: user_id, description: description})
    |> Repo.insert()
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
