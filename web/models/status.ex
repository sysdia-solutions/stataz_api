defmodule StatazApi.Status do
  use StatazApi.Web, :model

  schema "statuses" do
    field :description, :string, size: 32
    field :active, :boolean, default: false
    belongs_to :user, StatazApi.User

    timestamps
  end

  @required_fields ~w(description)
  @optional_fields ~w(active user_id)

  def by_user_id_exclude_id(user_id, exclude_id) do
    from s in StatazApi.Status,
    where: s.user_id == ^user_id and s.id != ^exclude_id
  end

  def by_user_id(user_id) do
    from s in StatazApi.Status,
    where: s.user_id == ^user_id
  end

  def by_id_and_active(id, active) do
    from s in StatazApi.Status,
    where: s.id == ^id and s.active == ^active
  end

  def profile_by_user_id(user_id, limit) do
    from h in StatazApi.History,
    where: h.user_id == ^user_id,
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: ^limit,
    preload: [:user]
  end

  def list_by(type, query, limit \\ 10, offset \\ 0)

  def list_by(:status, query, limit, offset) do
    from h in StatazApi.History,
    where: ilike(h.description, ^("%#{query}%")),
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:user, query, limit, offset) do
    from h in StatazApi.History,
    join: u in StatazApi.User, on: u.id == h.user_id,
    where: ilike(u.username, ^("%#{query}%")) or ilike(u.email, ^("%#{query}%")),
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:description, min: 2, max: 32)
    |> foreign_key_constraint(:user_id)
  end
end
