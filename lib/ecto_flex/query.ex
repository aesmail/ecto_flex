defmodule EctoFlex.FlexQuery do
  import Ecto.Query

  @maximum_per_page_limit "100"

  def filter(queryable, params, last_binding \\ false) do
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
    |> filter(options, true)
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
