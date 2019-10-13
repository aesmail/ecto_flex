# EctoFlex

EctoFlex is a flexible way to query schemas.

It's in very early development and is not yet ready for production use,
missing a lot of features that will be added hopefully fairly quickly.

PRs are welcome.

## Installation

Please note that `v0.2.0` contains breaking changes

```elixir
def deps do
  [
    {:ecto_flex, "~> 0.2.0"}
  ]
end
```

## Usage

Assuming you have an Employee schema, get all employees whose last names is "Example" aged between 40 and 42, married, and their description contains the term "motivated".

```elixir
alias EctoFlex.FlexQuery

conditions = %{
  "name" => %{"last_name" => "Example"},
  "age" => %{"is" => [40, 41, 42]},
  "married" => %{"is" => true},
  "description" => %{"contains" => "motivated"}
}

# this returns an %Ecto.Query{}
FlexQuery.filter(Employee, conditions)
```

### Associations

Get all young employees who work in HR and Marketing.

```elixir
conditions = %{
  "age" => %{"is" => [20, 21, 22, 23, 24]},
  "@department" => %{
    "name" => %{"is" => ["HR", "Marketing"]}
  },
  "married" => %{"is" => true}
}

FlexQuery.filter(Employee, conditions)
```

### Simple pagination

Get the 2nd page of employees whose salary is higher than $40,000, ordered descendingly by salary.

```elixir
conditions = %{
  "flex" => %{"page" => 2, "per_page" => 50, "order" => "-salary"}
  "salary" => %{"greater_than" => 40_000}
}

FlexQuery.filter(Employee, conditions)
```