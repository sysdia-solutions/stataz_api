defmodule StatazApi.Repo.Migrations.CreateRefreshToken do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :client_id, :string
      add :token_hash, :string

      timestamps
    end

    create index(:refresh_tokens, [:user_id])
  end
end
