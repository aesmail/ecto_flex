defmodule EctoFlex.FlexQuery do
  @moduledoc """
    This module has only one public-facing function, the `filter/2` function.
  """
  import Ecto.Query

  @maximum_per_page_limit "100"

  @doc """
    This function takes an `Ecto.Queryable`, usually an `Ecto.Schema`, as the first argument, and a map as a second argument, and returns an `Ecto.Query`.

    The second argument could take the following form:
        iex> %{
        iex>   "field1" => %{"filter1" => value1},
        iex>   "field2" => %{"filter2" => value2},
        iex>   "@association" => %{"assoc_field1" => %{"filter3" => value3}},
        iex> }
    The map must adhere to the following rules:

    1. Keys must be strings.
    2. Keys must map to schema fields, unless they have special meanings to EctoFlex (see below for more).
    3. Values are maps themselves.
    4. Each value map key must be one of the predefined "filters" (see below for more).
    5. Association keys start with `@` followed by the association name defined in the schema.
    6. Association key values must adhere to this list (see point 1).

  ## Sepcial Keys

    Aside from schema fields, EctoFlex treats some keys in a special way. Currently only 1 special key is supported:

    1. `flex`
        - When EctoFlex finds the `flex` key, it looks in the value (a map) for some configurations.
        For example, the following will get the first 10 records ordered by name ascendingly:
        `%{"flex" => %{"page" => 1, "per_page" => 10, "order" => "name"}}`
        - So far, there are only 3 supported `flex` configurations: `page`, `per_page`, and `order`.
        - To order descendingly, prefix the field name with a minus sign: `%{"order" => "-name"}`

  ## Filters

    Supported filters are:

    1. `is`: `%{"age" => %{"is" => 35}}`
    2. `contains`: `%{"name" => %{"contains" => "tina"}}`
    3. `greater_than`: `%{"birthdate" => %{"greater_than" => yesterday}}`
    4. `less_than`: `%{"age" => %{"less_than" => 21}}`

    Filter values could be either a single value or a list. If a list is provided, the values in the list will be `OR`d together:
    The filter

    `%{"age" => %{"is" => [20, 21]}}`

    means: Get me all records with "age" being either 20 or 21.

  ## Associations

    Assuming we have a `%User{}` which `has_many :addresses`, we could filter users by address:

    `%{"@addresses" => %{"city" => %{"is" => "Tokyo"}}}`

    This filter means: get me all users who have at least one address in Tokyo.

  ## Complete example

    ```
    alias EctoFlex.FlexQuery
    alias MyApp.Schemas.User
    alias MyApp.Repo

    conditions = %{ # get me all users
      "age" => %{"greater_than" => 20}, # who are older than 20 years old
      "email" => %{"contains" => "@gmail.com"}, # who registered with their gmail account
      "@posts" => %{"inserted_at" => %{"greater_than" => yesterday}}, # who created a post today
      "flex" => %{"order" => "-age", "page" => 1, "per_page" => 10}, # the top 10, ordered by age, oldest to youngest.
    }
    FlexQuery.filter(User, conditions) |> Repo.all()
    ```
  """
  @spec filter(Ecto.Queryable.t(), map()) :: Ecto.Query.t()
  def filter(queryable, params), do: do_filter(queryable, params, false)

  defp do_filter(queryable, params, last_binding) do
    keys = Map.keys(params)

    Enum.reduce(keys, queryable, fn key, final_query ->
      build_query(final_query, key, params[key], last_binding)
    end)
  end

  defp build_query(query, "flex", options, last_binding) do
    query
    |> build_pagination(options)
    |> build_ordering(options, last_binding)
  end

  defp build_query(query, "@" <> relation, options, _last_binding) do
    relation = String.to_existing_atom(relation)

    from(q in query, join: r in assoc(q, ^relation))
    |> do_filter(options, true)
  end

  defp build_query(query, key, options, last_binding) do
    f = String.to_existing_atom(key)
    build_field_conditions(query, f, options, last_binding)
  end

  defp build_pagination(query, %{"page" => _} = options) do
    page_param = Map.get(options, "page")
    per_page_param = Map.get(options, "per_page", @maximum_per_page_limit)
    page = if is_binary(page_param), do: String.to_integer(page_param), else: page_param

    per_page =
      if is_binary(per_page_param), do: String.to_integer(per_page_param), else: per_page_param

    offset = (page - 1) * per_page

    from(q in query, offset: ^offset, limit: ^per_page)
  end

  defp build_pagination(query, _), do: query

  defp build_ordering(query, %{"order" => order}, last_binding) do
    case String.starts_with?(order, "-") do
      true ->
        "-" <> f = order
        f = String.to_existing_atom(f)

        if last_binding do
          from([..., q] in query, order_by: [desc: field(q, ^f)])
        else
          from(q in query, order_by: [desc: field(q, ^f)])
        end

      false ->
        order = String.to_existing_atom(order)

        if last_binding do
          from([..., q] in query, order_by: [asc: field(q, ^order)])
        else
          from(q in query, order_by: [asc: field(q, ^order)])
        end
    end
  end

  defp build_ordering(query, _, _), do: query

  defp build_field_conditions(query, f, options, last_binding) do
    option_keys = Map.keys(options)

    Enum.reduce(option_keys, query, fn key, final_query ->
      build_options(final_query, f, key, options[key], last_binding)
    end)
  end

  defp build_options(query, f, condition, values, last_binding) when is_list(values) do
    case condition do
      "is" ->
        conditions = build_is_dynamic(f, values, last_binding)
        from(query, where: ^conditions)

      "contains" ->
        conditions = build_contains_dynamic(f, values, last_binding)
        from(query, where: ^conditions)

      _ ->
        query
    end
  end

  defp build_options(query, f, condition, value, last_binding) do
    if last_binding do
      case condition do
        "is" -> from([..., q] in query, where: field(q, ^f) == ^value)
        "contains" -> from([..., q] in query, where: like(field(q, ^f), ^"%#{value}%"))
        "greater_than" -> from([..., q] in query, where: field(q, ^f) > ^value)
        "less_than" -> from([..., q] in query, where: field(q, ^f) < ^value)
        _ -> query
      end
    else
      case condition do
        "is" -> from(q in query, where: field(q, ^f) == ^value)
        "contains" -> from(q in query, where: like(field(q, ^f), ^"%#{value}%"))
        "greater_than" -> from(q in query, where: field(q, ^f) > ^value)
        "less_than" -> from(q in query, where: field(q, ^f) < ^value)
        _ -> query
      end
    end
  end

  defp build_is_dynamic(f, values, last_binding) do
    Enum.reduce(values, false, fn v, final_dynamic ->
      if last_binding do
        dynamic([..., q], field(q, ^f) == ^v or ^final_dynamic)
      else
        dynamic([q], field(q, ^f) == ^v or ^final_dynamic)
      end
    end)
  end

  defp build_contains_dynamic(f, values, last_binding) do
    Enum.reduce(values, false, fn v, final_dynamic ->
      if last_binding do
        dynamic([..., q], like(field(q, ^f), ^v) or ^final_dynamic)
      else
        dynamic([q], like(field(q, ^f), ^v) or ^final_dynamic)
      end
    end)
  end
end
