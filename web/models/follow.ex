defmodule StatazApi.Follow do
  use StatazApi.Web, :model

  schema "follows" do
    belongs_to :follower, StatazApi.User, foreign_key: :follower_id
    belongs_to :following, StatazApi.User, foreign_key: :following_id

    timestamps
  end

  @required_fields ~w(follower_id following_id)

  def by_follower_id_and_following_id(follower_id, following_id) do
    from f in StatazApi.Follow,
    where: f.follower_id == ^follower_id and f.following_id == ^following_id
  end

  def by_type_id(your_type, their_type, user_id) do
    from f in StatazApi.Follow,
    join: u in StatazApi.User, on: field(f, ^their_type) == u.id,
    join: s in StatazApi.Status, on: u.id == s.user_id and s.active == true,
    where: field(f, ^your_type) == ^user_id,
    order_by: [desc: f.inserted_at, desc: f.id],
    select: {u.username, f.inserted_at, s.description}
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, [])
    |> foreign_key_constraint(:follower_id)
    |> foreign_key_constraint(:following_id)
    |> follow_self?()
  end

  defp follow_self?(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        if get_change(changeset, :follower_id) == get_change(changeset, :following_id) do
          add_error(changeset, :following_id, "can't be the same")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end
