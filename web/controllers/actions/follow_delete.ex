defmodule StatazApi.FollowController.ActionDelete do
  use StatazApi.Web, :controller
  alias StatazApi.Follow

  def execute(conn, %{"username" => username}) do
    Repo.get_by(StatazApi.User, %{username: username})
    |> delete(conn.assigns.current_user)
    |> response(conn)
  end

  def execute(conn, _params) do
    put_status(conn, :unprocessable_entity)
    |> render("show.json", error: :unprocessable_entity)
  end

  defp delete(following_user = %StatazApi.User{}, follower_user) do
    Follow.by_follower_id_and_following_id(follower_user.id, following_user.id)
    |> Repo.delete_all()
  end

  defp delete(nil, _follower_user) do
    {:error, :not_found}
  end

  defp response({:error, error}, conn) do
    put_status(conn, error)
    |> render("show.json", error: error)
  end

  defp response({0, _}, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end

  defp response({_rows, _}, conn) do
    send_resp(conn, :no_content, "")
  end
end
