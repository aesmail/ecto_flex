defmodule EctoFlex.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, size: 100)
      add(:age, :integer)
      add(:birthdate, :date)
      add(:description, :string, size: 100)
      add(:status, :string, size: 20, default: "single", null: false)
      add(:gender, :string, size: 1, null: false, defautl: "m")
      add(:alive, :boolean, default: true, null: false)
    end
  end
end
