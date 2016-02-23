defmodule StatazApi.History do
  use StatazApi.Web, :model

  schema "histories" do
    field :description, :string, size: 32
    belongs_to :user, StatazApi.User

    timestamps
  end

  @required_fields ~w(description)
  @optional_fields ~w(user_id)

  def list_by(type, model, query, limit \\ 10, offset \\ 0)

  def list_by(:default, :status, query, limit, offset) do
    from h in StatazApi.History,
    where: ilike(h.description, ^("%#{query}%")),
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: ^limit,
    offset: ^offset,
    preload: [:user]
  end

  def list_by(:default, :user, query, limit, offset) do
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
