defmodule EctoFlex.FlexQuery do
  import Ecto.Query

  def filter(queryable, params) do
    queryable
    |> construct_equals(params)
    |> construct_contains(params)
  end

  defp construct_equals(queryable, %{equals: equals}) when is_list(equals) do
    Enum.reduce(equals, queryable, fn {k, v}, final_query ->
      construct_equals(final_query, %{equals: {k, v}})
    end)
  end

  defp construct_equals(queryable, %{equals: {k, vs}}) when is_list(vs) do
    conditions =
      Enum.reduce(vs, false, fn v, final_dynamic ->
        dynamic([q], field(q, ^k) == ^v or ^final_dynamic)
      end)

    from(queryable, where: ^conditions)
  end

  defp construct_equals(queryable, %{equals: {k, v}}) do
    IO.puts("Constructing #{k} with #{v}")
    query = from(q in queryable, where: field(q, ^k) == ^v)
    IO.inspect(query)
    query
  end

  defp construct_equals(queryable, _), do: queryable

  defp construct_contains(queryable, %{contains: contains}) when is_list(contains) do
    Enum.reduce(contains, queryable, fn {k, v}, final_query ->
      construct_contains(final_query, %{contains: {k, v}})
    end)
  end

  defp construct_contains(queryable, %{contains: {k, vs}}) when is_list(vs) do
    conditions =
      Enum.reduce(vs, false, fn v, final_dynamic ->
        dynamic([q], like(field(q, ^k), ^v) or ^final_dynamic)
      end)

    from(queryable, where: ^conditions)
  end

  defp construct_contains(queryable, %{contains: {k, v}}) do
    IO.puts("Constructing #{k} with #{v}")
    query = from(q in queryable, where: like(field(q, ^k), ^v))
    IO.inspect(query)
    query
  end

  defp construct_contains(queryable, _), do: queryable
end
