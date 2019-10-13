defmodule EctoFlex.Repo.Migrations.CreateHobbies do
  use Ecto.Migration

  def change do
    create table(:hobbies) do
      add(:name, :string, size: 100, null: false)
    end
  end
end
