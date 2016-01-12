defmodule StatazApi.UserController.ActionCreate do
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, user_params) do
    User.create_changeset(%User{}, user_params)
    |> Repo.insert()
    |> response(conn)
  end

  defp response({:ok, user}, conn) do
    seed_default_status(user)
    conn
    |> put_status(:created)
    |> put_resp_header("location", user_path(conn, :show))
    |> render("show.json", user: user)
  end

  defp response({:error, changeset}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(StatazApi.ChangesetView, "error.json", changeset: changeset)
  end

  defp seed_default_status(user = %User{}) do
    default_status = Gettext.dgettext(StatazApi.Gettext, "text", "new")
    {:ok, status} = StatazApi.StatusController.ActionCreate.build(user.id, default_status)
    StatazApi.StatusController.ActionUpdate.build(status, %{"active" => true}, user.id)
  end
end
