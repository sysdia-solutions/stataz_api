defmodule StatazApi.Profile do
  import Ecto.Query, only: [from: 1, from: 2]

  def by_user_id(user_id) do
    from s in StatazApi.Status,
    join: u in StatazApi.User, on: s.user_id == u.id,
    where: s.user_id == ^user_id and s.active == true,
    preload: [user: u]
  end
end
