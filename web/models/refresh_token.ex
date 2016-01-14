defmodule StatazApi.RefreshToken do
  use StatazApi.Web, :model

  schema "refresh_tokens" do
    field :client_id, :string
    field :token, :string, virtual: true
    field :token_hash, :string
    belongs_to :user, StatazApi.User

    timestamps
  end

  @required_fields ~w(client_id token)
  @optional_fields ~w(user_id)

  def by_user_id(user_id) do
    from t in StatazApi.RefreshToken,
    where: t.user_id == ^user_id
  end

  def by_client_id_and_token(client_id, token) do
    from t in StatazApi.RefreshToken,
    where: t.client_id == ^client_id and t.token_hash == ^hash(token)
  end

  def by_client_id_and_user_id(client_id, user_id) do
    from t in StatazApi.RefreshToken,
    where: t.client_id == ^client_id and t.user_id == ^user_id
  end

  def by_client_id_excluding_id(client_id, exclude_id) do
    from t in StatazApi.RefreshToken,
    where: t.client_id == ^client_id and t.id != ^exclude_id
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:client_id, min: 8, max: 100)
    |> foreign_key_constraint(:user_id)
    |> put_token()
  end

  defp put_token(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{token: token}} ->
        put_change(changeset, :token_hash, hash(token))
      _ ->
        changeset
    end
  end

  defp hash(string) do
    :crypto.hash(:sha512, string)
    |> Base.encode16
  end
end
