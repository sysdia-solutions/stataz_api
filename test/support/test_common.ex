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
end
