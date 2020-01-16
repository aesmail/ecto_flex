# EctoFlex

EctoFlex is a flexible way to query schemas.

It's in very early development and is not yet ready for production use,
missing a lot of features that will be added hopefully fairly quickly.

PRs are welcome.

## Installation

```elixir
def deps do
  [
    {:ecto_flex, "~> 0.4.0"}
  ]
end
```

This function takes an `Ecto.Queryable`, usually an `Ecto.Schema`, as the first argument, and a map as a second argument, and returns an `Ecto.Query`.

The second argument could take the following form:
```elixir
%{
  "field1" => %{"filter1" => value1},
  "field2" => %{"filter2" => value2},
  "@association" => %{"assoc_field1" => %{"filter3" => value3}},
}
```
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

  1. is: `%{"age" => %{"is" => 35}}`
  2. contains: `%{"name" => %{"contains" => "tina"}}`
  3. greater_than: `%{"birthdate" => %{"greater_than" => yesterday}}`
  4. less_than: `%{"age" => %{"less_than" => 21}}`

Filter values could be either a single value or a list. If a list is provided, the values in the list will be `OR`d together:
The filter

`%{"age" => %{"is" => [20, 21]}}`

means: Get me all records with "age" being either 20 or 21.

## Associations

Assuming we have a `%User{}` which `has_many :addresses`, we could filter users by address:

`%{"@addresses" => %{"city" => %{"is" => "Tokyo"}}}`

This filter means: get me all users who have at least one address in Tokyo.

## Complete example

```elixir
alias EctoFlex.FlexQuery
alias MyApp.Schemas.User
alias MyApp.Repo

conditions = %{ # get me all users
  "age" => %{"greater_than" => 20}, # who are older than 20 years old
  "email" => %{"contains" => "@gmail.com"}, # who registered with their gmail account
  "phone" => %{"not" => nil}, # who have phone numbers on record
  "@posts" => %{"inserted_at" => %{"greater_than" => yesterday}}, # who created a post today
  "flex" => %{"order" => "-age", "page" => 1, "per_page" => 10}, # the top 10, ordered by age, oldest to youngest.
}
FlexQuery.filter(User, conditions) |> Repo.all()
```

## Changelogs

### v0.5.0 (in development)
 * Added support for `NOT NULL`. You can now do `%{"field" => %{"not" => nil}}`.

### v0.4.1

 * Added support for `nil` values. You can now do `%{"field" => %{"is" => nil}}` and the query will be constructed properly.
