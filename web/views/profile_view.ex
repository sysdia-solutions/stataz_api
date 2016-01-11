defmodule StatazApi.ProfileView do
  use StatazApi.Web, :view

  def render("show.json", %{profile: profile}) do
    %{data: render_one(List.first(profile), StatazApi.ProfileView, "profile.json")}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end

  def render("profile.json", %{profile: profile}) do
    %{username: profile.user.username,
      status: profile.description,
      since: profile.updated_at}
  end
end
