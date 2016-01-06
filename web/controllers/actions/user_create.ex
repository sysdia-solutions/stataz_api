defmodule StatazApi.UserController.ActionCreate do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, user_params) do
    User.create_changeset(%User{}, user_params)
    |> Repo.insert()
    |> response(conn)
  end

  defp response({:ok, user}, conn) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", user_path(conn, :show, user.username))
    |> render("show.json", user: user)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end
end
