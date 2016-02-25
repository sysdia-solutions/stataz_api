defmodule StatazApi.History do
  use StatazApi.Web, :model

  schema "histories" do
    field :description, :string, size: 32
    belongs_to :user, StatazApi.User

    timestamps
  end

  @required_fields ~w(description)
  @optional_fields ~w(user_id)

  def profile_by_user_id(user_id, limit) do
    from h in StatazApi.History,
    where: h.user_id == ^user_id,
    order_by: [desc: h.inserted_at, desc: h.id],
    limit: ^limit,
    preload: [:user]
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:description, min: 2, max: 32)
    |> foreign_key_constraint(:user_id)
  end
end
