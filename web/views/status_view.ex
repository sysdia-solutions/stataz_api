defmodule StatazApi.StatusView do
  use StatazApi.Web, :view

  def render("show.json", %{status: status}) do
    %{data: render_one(status, StatazApi.StatusView, "status.json")}
  end

  def render("list.json", %{status: status}) do
    %{data: render_many(status, StatazApi.StatusView, "status.json")}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end

  def render("status.json", %{status: status}) do
    %{id: status.id,
      description: status.description,
      active: status.active}
  end
end
