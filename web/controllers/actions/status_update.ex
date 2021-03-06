defmodule StatazApi.StatusController.ActionUpdate do
  use StatazApi.Web, :controller
  alias StatazApi.Status
  alias StatazApi.History

  def execute(conn, params) do
    Repo.get(Status, params["id"])
    |> check_set_active_true_to_false(params)
    |> update(conn, params)
  end

  def build(status = %Status{}, params, user_id) do
    Status.changeset(status, params)
    |> Repo.update()
    |> update_previous_active_true_to_false(params)
    |> active_status_to_history(user_id)
  end

  defp check_set_active_true_to_false(status = %Status{}, params) do
    if Map.has_key?(params, "active") and active_true_to_false?(%{"active" => status.active}, params) do
      {:error, :forbidden}
    else
      status
    end
  end

  defp check_set_active_true_to_false(nil, _params) do
    {:error, :not_found}
  end

  defp update({:error, status}, conn, _params) do
    put_status(conn, status)
    |> render("show.json", error: status)
  end

  defp update(status = %Status{}, conn, params) do
    build(status, params, conn.assigns.current_user.id)
    |> response(conn)
  end

  defp update_previous_active_true_to_false(status, params) do
    if active_true?(params) do
      {:ok, elements} = status
      Status.by_user_id_exclude_id(elements.user_id, elements.id)
      |> Repo.update_all(set: [active: false])
    end
    status
  end

  defp active_true?(params) do
    Map.has_key?(params, "active") and
    (
      params["active"] == true or
      params["active"] == "true" or
      params["active"] == "1"
    )
  end

  defp active_true_to_false?(params_1, params_2) do
    active_true?(params_1) and !active_true?(params_2)
  end

  defp active_status_to_history({:ok, status}, user_id) do
    if status.active do
      add_history(user_id, status.description)
    end
    {:ok, status}
  end

  defp active_status_to_history({:error, changeset}, _user_id) do
    {:error, changeset}
  end

  defp response({:ok, status}, conn) do
    conn
    |> put_status(:ok)
    |> render("show.json", status: status)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end

  defp add_history(user_id, description) do
    History.changeset(%History{}, %{user_id: user_id, description: description})
    |> Repo.insert()
  end
end
