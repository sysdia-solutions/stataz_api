defmodule StatazApi.FollowView do
  use StatazApi.Web, :view

  def render("show.json", %{follow: _follow}) do
    %{data: ""}
  end

  def render("show.json", %{error: error}) do
    %{errors:
      %{ title: StatazApi.ErrorHelpers.translate_error(to_string(error)) }
    }
  end

  def render("follow.json", %{follow: follow}) do
    {username, inserted_at, status} = follow
    %{username: username,
      since: StatazApi.Util.Time.ecto_datetime_simple_format(inserted_at),
      status: status}
  end

  def render("show.json", %{payload: payload}) do
    %{data:
      %{
        followers: render_many(payload.followers, StatazApi.FollowView, "follow.json"),
        following: render_many(payload.following, StatazApi.FollowView, "follow.json")
      }
    }
  end

end
