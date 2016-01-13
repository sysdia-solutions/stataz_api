defmodule StatazApi.FollowController.ActionCreate do
  use StatazApi.Web, :controller
  alias StatazApi.Follow

  def execute(conn, %{"username" => username}) do
    Repo.get_by(StatazApi.User, %{username: username})
    |> create(conn.assigns.current_user)
    |> response(conn)
  end

  def execute(conn, _params) do
    {:error, :http, :unprocessable_entity}
    |> response(conn)
  end

  defp create(following_user = %StatazApi.User{}, follower_user) do
    if not_following?(follower_user.id, following_user.id) do
      Follow.changeset(%Follow{}, %{follower_id: follower_user.id, following_id: following_user.id})
      |> Repo.insert()
    else
      {:error, :http, :forbidden}
    end
  end

  defp create(nil, _follower_user) do
    {:error, :http, :not_found}
  end

  defp not_following?(follower_id, following_id) do
    case Follow.by_follower_id_and_following_id(follower_id, following_id) |> Repo.all() do
      [] ->
        true
      _ ->
        false
    end
  end

  defp response({:ok, follow}, conn) do
    conn
    |> put_status(:created)
    |> render("show.json", follow: follow)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end

  defp response({:error, :http, error}, conn) do
    conn
    |> put_status(error)
    |> render("show.json", error: error)
  end
end
