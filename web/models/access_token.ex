defmodule StatazApi.AccessToken do
  use StatazApi.Web, :model

  schema "access_tokens" do
    field :token, :string, virtual: true
    field :token_hash, :string
    field :expires, Ecto.DateTime
    belongs_to :user, StatazApi.User

    timestamps
  end

  @required_fields ~w(token expires)
  @optional_fields ~w(user_id)

  def by_token(token) do
    from t in StatazApi.AccessToken,
    where: t.token_hash == ^hash(token)
  end

  def by_user_id(user_id) do
    from t in StatazApi.AccessToken,
    where: t.user_id == ^user_id
  end

  def by_user_id_and_token(user_id, token) do
    from t in StatazApi.AccessToken,
    where: t.user_id == ^user_id and t.token_hash == ^hash(token)
  end

  def by_all_expired(datetime) do
    from t in StatazApi.AccessToken,
    where: t.expires <= ^datetime
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
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
