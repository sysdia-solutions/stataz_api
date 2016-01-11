defmodule StatazApi.ProfileController do
  use StatazApi.Web, :controller
  alias StatazApi.User
  alias StatazApi.Profile

  def show(conn, %{"username" => username}) do
    Repo.get_by(User, %{username: username})
    |> response(conn)
  end

  defp response(user = %User{}, conn) do
    profile = Profile.by_user_id(user.id)
              |> Repo.all()
    render(conn, "show.json", profile: profile)
  end

  defp response(nil, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end
end
