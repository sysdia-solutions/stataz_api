defmodule StatazApi.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:histories) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :description, :string, size: 32

      timestamps
    end

    create index(:histories, [:user_id])
  end
end
