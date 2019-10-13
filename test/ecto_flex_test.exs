defmodule EctoFlexTest do
  use ExUnit.Case
  alias EctoFlexTest.Schemas.PersonTest
  alias EctoFlex.FlexQuery
  import Ecto.Query
  doctest EctoFlex

  test "building a simple query with joins" do
    conditions = %{
      "age" => %{"is" => [20, 21]},
      "name" => %{"contains" => "jon"},
      "@addresses" => %{
        "phone" => %{"is" => "123456789"},
        "street" => %{"is" => ["102", "87"]}
      },
      "married" => %{"is" => true},
      "flex" => %{"per_page" => 100, "page" => 2, "order" => "-name"}
    }

    # |> clean_query()
    flex_query = FlexQuery.filter(PersonTest, conditions)
    IO.inspect(flex_query)
  end
end
