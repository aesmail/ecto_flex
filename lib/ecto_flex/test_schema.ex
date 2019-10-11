defmodule EctoFlex.TestSchema do
  use Ecto.Schema

  schema "testing" do
    field(:name, :string)
    field(:age, :integer)
    field(:status, :string)
    field(:married, :boolean, default: false)
  end
end
