defmodule StatazApi.Repo.Migrations.CreateAccessToken do
  use Ecto.Migration

  def change do
    create table(:access_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token_hash, :string
      add :expires, :datetime

      timestamps
    end

    create index(:access_tokens, [:user_id])
  end
end
