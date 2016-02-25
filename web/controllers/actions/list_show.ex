defmodule StatazApi.ListController.ActionShow do
  use StatazApi.Web, :controller

  def execute(conn, params, type, model) do
    {limit, offset} = StatazApi.Util.Params.get_limit_offset(params)

    StatazApi.Status.list_by(type, model, "", limit, offset)
    |> Repo.all()
    |> response(conn, {type, model})
  end

  defp response(nil, conn, _type) do
    conn
    |> put_status(:not_found)
    |> render(StatazApi.StatusView, "show.json", error: :not_found)
  end

  defp response(results, conn, {:new, _model}) do
    conn
    |> put_status(:ok)
    |> render(StatazApi.StatusView, "show.json", profile: results)
  end

  defp response(results, conn, {:popular, :status}) do
    conn
    |> put_status(:ok)
    |> render(StatazApi.StatusView, "show.json", count: results)
  end
end
