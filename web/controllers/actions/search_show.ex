defmodule StatazApi.SearchController.ActionShow do
  use StatazApi.Web, :controller

  defp get_value(data, default) do
    if data, do: data, else: default
  end

  def execute(conn, params, type) do
    limit = get_value(params["limit"], 10)
    offset = get_value(params["offset"], 0)

    StatazApi.Status.list_by(type, params["query"], limit, offset)
    |> Repo.all()
    |> response(conn)
  end

  defp response(nil, conn) do
    conn
    |> put_status(:not_found)
    |> render(StatazApi.StatusView, "show.json", error: :not_found)
  end

  defp response(results, conn) do
    conn
    |> put_status(:ok)
    |> render(StatazApi.StatusView, "show.json", profile: results)
  end
end
