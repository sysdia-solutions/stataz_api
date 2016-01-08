defmodule StatazApi.UserController.ActionUpdate do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, username) do
    user_params = conn.body_params
    Repo.get_by(User, %{username: username})
    |> update(conn, user_params)
  end

  defp update(user = %User{}, conn, user_params) do
    User.update_changeset(user, user_params)
    |> Repo.update()
    |> response(conn)
  end

  defp update(nil, conn, _user_params) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end

  defp response({:ok, user}, conn) do
    conn
    |> put_status(:ok)
    |> render("show.json", user: user)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end
end
