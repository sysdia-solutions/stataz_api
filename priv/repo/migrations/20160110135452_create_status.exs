defmodule StatazApi.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :description, :string, size: 32
      add :active, :boolean, default: false

      timestamps
    end

    create index(:statuses, [:user_id])
  end
end
