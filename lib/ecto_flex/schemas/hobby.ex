defmodule EctoFlex.Schemas.Hobby do
  @moduledoc false
  import Ecto.Changeset
  use Ecto.Schema

  schema "hobbies" do
    field(:name, :string)
    has_many(:users, EctoFlex.Schemas.User)
  end

  def changeset(hobby, params) do
    hobby
    |> cast(params, [:name])
  end
end
