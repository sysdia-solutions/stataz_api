defmodule StatazApi.SearchController.ActionShow do
  use StatazApi.Web, :controller

  def execute(conn, params, model) do
    {limit, offset} = StatazApi.Util.Params.get_limit_offset(params)

    StatazApi.Status.list_by(:search, model, params["query"], limit, offset)
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
