defmodule EctoFlexTest do
  use ExUnit.Case
  alias EctoFlexTest.Schemas.PersonTest
  alias EctoFlex.FlexQuery
  import Ecto.Query
  doctest EctoFlex

  test "equals with a list of fields" do
    conditions = %{equals: [{:age, 23}, {:active, true}]}
    flex_query = FlexQuery.filter(PersonTest, conditions) |> clean_query()

    ecto_query =
      from(t in PersonTest, where: t.age == ^23)
      |> where([t], t.active == ^true)
      |> clean_query()

    assert flex_query == ecto_query
  end

  test "contains with a list of fields" do
    conditions = %{contains: [{:name, "%jon%"}, {:description, "%good%"}]}
    flex_query = FlexQuery.filter(PersonTest, conditions) |> clean_query()

    ecto_query =
      from(t in PersonTest, where: like(t.name, ^"%jon%"))
      |> where([t], like(t.description, ^"%good%"))
      |> clean_query()

    assert flex_query == ecto_query
  end

  defp clean_query(query), do: remove_code_info_from_query(query)

  defp remove_code_info_from_query(query) do
    q = Map.from_struct(query)
    wheres = q[:wheres]
    clean_wheres = Enum.map(wheres, fn w -> Map.drop(w, [:file, :line]) end)
    Map.put(q, :wheres, clean_wheres)
  end
end
