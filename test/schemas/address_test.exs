defmodule EctoFlexTest.Schemas.AddressTest do
  use Ecto.Schema

  schema "address_testing" do
    field(:street, :string)
    field(:phone, :string)
    belongs_to(:person, EctoFlexTest.Schemas.PersonTest)
  end
end
