defmodule StatazApi.UserView do
  use StatazApi.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, StatazApi.UserView, "user.json")}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.display_name,
      email: user.email}
  end
end
