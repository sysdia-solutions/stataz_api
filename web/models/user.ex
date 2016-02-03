defmodule StatazApi.User do
  use StatazApi.Web, :model

  schema "users" do
    field :username, :string
    field :display_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string

    timestamps
  end

  def by_username(username) do
    from u in StatazApi.User,
    where: u.username == ^String.downcase(username)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(username), ~w(email))
    |> put_display_name()
    |> validate_length(:username, min: 3, max: 20)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def create_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password email), [])
    |> validate_length(:password, min: 8, max: 100)
    |> put_password_hash()
  end

  def update_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, [], ~w(password email))
    |> validate_not_changed(:username)
    |> validate_length(:password, min: 8, max: 100)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp put_display_name(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: user}} ->
        put_change(changeset, :display_name, user)
        |> put_change(:username, String.downcase(user))
      _ ->
        changeset
    end
  end

  defp validate_not_changed(changeset, field) do
    case get_change(changeset, field) do
      nil ->
        changeset
      _ ->
        add_error(changeset, field, "can't be changed")
    end
  end
end
