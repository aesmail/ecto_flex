defmodule EctoFlexTest.Schemas.PersonTest do
  use Ecto.Schema

  schema "testers" do
    field(:name, :string)
    field(:age, :integer)
    field(:birthdate, :naive_datetime)
    field(:description, :string)
    field(:active, :boolean)
  end
end
