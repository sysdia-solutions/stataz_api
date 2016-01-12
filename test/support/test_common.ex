defmodule StatazApi.TestCommon do
  def build_token(repo, user_id, token, expiry_seconds) do
    expires = StatazApi.Util.Time.ecto_now()
              |> StatazApi.Util.Time.ecto_shift(secs: expiry_seconds)

    StatazApi.AccessToken.changeset(%StatazApi.AccessToken{}, %{user_id: user_id, token: token, expires: expires})
    |> repo.insert()
  end

  def create_user(repo, username, password, email) do
    StatazApi.User.create_changeset(%StatazApi.User{}, %{username: username, password: password, email: email})
    |> repo.insert!()
  end

  def create_status(repo, user_id, description, active) do
    StatazApi.Status.changeset(%StatazApi.Status{}, %{user_id: user_id, description: description, active: active})
    |> repo.insert!()
    |> create_history(repo, user_id)
  end

  def create_history({:error, changeset}, _repo, _user_id) do
  end

  def create_history(status = %StatazApi.Status{}, repo, user_id) do
    if status.active do
      StatazApi.History.changeset(%StatazApi.History{}, %{user_id: user_id, description: status.description})
      |> repo.insert!()
    end
    status
  end
end
