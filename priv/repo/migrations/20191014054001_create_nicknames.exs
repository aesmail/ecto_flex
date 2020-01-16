defmodule EctoFlex.Repo.Migrations.CreateNicknames do
  use Ecto.Migration

  def change do
    create table(:nicknames) do
      add(:name, :map)
      add(:user_id, references(:users, on_delete: :nothing), null: false)
    end

    create(index(:nicknames, [:user_id]))
  end
end
