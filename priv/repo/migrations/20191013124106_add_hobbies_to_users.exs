defmodule EctoFlex.Repo.Migrations.AddHobbiesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:hobby_id, references(:hobbies, on_delete: :nothing))
    end
  end
end
