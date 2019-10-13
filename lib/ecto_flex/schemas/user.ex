defmodule EctoFlex.Schemas.User do
  @moduledoc false
  import Ecto.Changeset
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:age, :integer)
    field(:birthdate, :date)
    field(:description, :string)
    field(:status, :string)
    field(:alive, :boolean)
    field(:gender, :string)
    belongs_to(:hobby, EctoFlex.Schemas.Hobby)
  end

  def changeset(user, params) do
    user
    |> cast(params, [:name, :age, :birthdate, :description, :status, :alive, :gender, :hobby_id])
  end
end
