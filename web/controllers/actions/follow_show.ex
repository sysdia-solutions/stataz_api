defmodule StatazApi.FollowController.ActionShow do
  use StatazApi.Web, :controller
  alias StatazApi.Follow

  def execute(conn, %{"username" => username}) do
    Repo.get_by(StatazApi.User, %{username: username})
    |> show(conn)
  end

  def execute(conn, _params) do
    show(conn.assigns.current_user, conn)
  end

  defp show(nil, conn) do
    conn
    |> put_status(:not_found)
    |> render("show.json", error: :not_found)
  end

  defp show(user = %StatazApi.User{}, conn) do
    followers = Follow.by_type_id(:following_id, :follower_id, user.id)
                |> Repo.all()
    following = Follow.by_type_id(:follower_id, :following_id, user.id)
                |> Repo.all()

    response(conn, followers, following)
  end

  defp response(conn, followers, following) do
    conn
    |> put_status(:ok)
    |> render("show.json", payload: %{followers: followers, following: following})
  end
end
