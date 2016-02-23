defmodule StatazApi.ListController.ActionShow do
  use StatazApi.Web, :controller

  def execute(conn, params, :popular, :status) do
    {limit, offset} = StatazApi.Util.Params.get_limit_offset(params)

    StatazApi.Status.list_by_count(limit, offset)
    |> Repo.all()
    |> response(conn, :status_count)
  end

  def execute(conn, params, type, model) do
    {limit, offset} = StatazApi.Util.Params.get_limit_offset(params)

    StatazApi.History.list_by(type, model, params["query"], limit, offset)
    |> Repo.all()
    |> response(conn, :profile)
  end

  defp response(nil, conn, _type) do
    conn
    |> put_status(:not_found)
    |> render(StatazApi.StatusView, "show.json", error: :not_found)
  end

  defp response(results, conn, :profile) do
    conn
    |> put_status(:ok)
    |> render(StatazApi.StatusView, "show.json", profile: results)
  end

  defp response(results, conn, :status_count) do
    conn
    |> put_status(:ok)
    |> render(StatazApi.StatusView, "show.json", count: results)
  end
end
