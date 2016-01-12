defmodule StatazApi.Profile do
  import Ecto.Query, only: [from: 1, from: 2]

  def by_user_id(user_id) do
    from h in StatazApi.History,
    join: u in StatazApi.User, on: h.user_id == u.id,
    where: h.user_id == ^user_id,
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: 5,
    preload: [user: u]
  end
end
