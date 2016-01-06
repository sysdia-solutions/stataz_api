defmodule StatazApi.UserView do
  use StatazApi.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, StatazApi.UserView, "user.json")}
  end

  def render("show.json", %{error: error}) do
    error
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email}
  end
end
