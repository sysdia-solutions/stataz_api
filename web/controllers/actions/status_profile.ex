defmodule StatazApi.StatusController.ActionProfile do
  use StatazApi.Web, :controller
  alias StatazApi.User
  alias StatazApi.Status

  def execute(conn, %{"username" => username}) do
    User.by_username(username)
    |> Repo.one()
    |> response(conn)
  end

  defp response(user = %User{}, conn) do
    profile = Status.profile_by_user_id(user.id, 5)
              |> Repo.all()
    render(conn, "show.json", profile: profile)
  end

  defp response(nil, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end
end
