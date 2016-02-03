defmodule StatazApi.Repo.Migrations.UserAddColumnDisplayName do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :display_name, :string, null: false
    end
  end
end
