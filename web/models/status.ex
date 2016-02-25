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

  def list_by(type, model, query, limit \\ 10, offset \\ 0)

  def list_by(:search, :status, query, limit, offset) do
    from s in StatazApi.Status,
    where: s.active == true and ilike(s.description, ^("%#{query}%")),
    order_by: [desc: s.updated_at, desc: s.id],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:search, :user, query, limit, offset) do
    from s in StatazApi.Status,
    join: u in StatazApi.User, on: u.id == s.user_id,
    where: s.active == true and
           (
             ilike(u.username, ^("%#{query}%")) or
             ilike(u.email, ^("%#{query}%"))
           ),
    order_by: [asc: u.username],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:new, :user, _query, limit, offset) do
    from s in StatazApi.Status,
    join: u in StatazApi.User, on: u.id == s.user_id,
    where: s.active == true,
    order_by: [desc: u.inserted_at],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:new, :status, _query, limit, offset) do
    from s in StatazApi.Status,
    join: u in StatazApi.User, on: u.id == s.user_id,
    where: s.active == true,
    order_by: [desc: s.updated_at, desc: s.id],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:popular, :status, _query, limit, offset) do
    from s in StatazApi.Status,
    where: s.active == true,
    group_by: s.description,
    limit: ^limit,
    offset: ^offset,
    select: {s.description, count(s.id)}
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:description, min: 2, max: 32)
    |> foreign_key_constraint(:user_id)
  end
end
