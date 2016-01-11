defmodule StatazApi.UserController.ActionUpdate do
  import Comeonin.Bcrypt, only: [checkpw: 2]
  use StatazApi.Web, :controller
  alias StatazApi.User

  def execute(conn, params) do
    user = Repo.get(User, conn.assigns.current_user.id)

    Map.delete(params, "password")
    |> check_password_change(user)
    |> update(user, conn)
  end

  defp check_password_change(params, user = %User{}) do
    if Map.get(params, "new_password") && Map.get(params, "old_password") do
      checkpw(params["old_password"], user.password_hash)
      |> update_params_password(params)
    else
      params
    end
  end

  defp check_password_change(params, nil) do
    params
  end

  defp update_params_password(true, params) do
    Map.put(params, "password", params["new_password"])
  end

  defp update_params_password(false, _params) do
    {:error, :unauthorized}
  end

  defp update({:error, status}, _user, conn) do
    put_status(conn, status)
    |> render("show.json", error: status)
  end

  defp update(_params, nil, conn) do
    put_status(conn, :not_found)
    |> render("show.json", error: :not_found)
  end

  defp update(params, user = %User{}, conn) do
    User.update_changeset(user, params)
    |> password_changed?(conn)
    |> Repo.update()
    |> response(conn)
  end

  defp password_changed?(changeset, conn) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: _password}} ->
        StatazApi.Auth.purge_tokens(conn, Repo)
        changeset
      _ ->
        changeset
    end
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
