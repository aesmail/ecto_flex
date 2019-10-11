# EctoFlex

EctoFlex is a flexible way to query schemas.

It's in very early development and is not yet ready for production use,
missing a lot of features that will be added hopefully fairly quickly.

PRs are welcome.

## Installation

```elixir
def deps do
  [
    {:ecto_flex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
alias EctoFlex.FlexQuery

# get employees whose names start with Joe, aged between 40 and 42, married,
# and their description contains the term "motivated" 
conditions = %{
  equals: [{:age, [40, 41, 42]}, {:married, true}],
  contains: [{:description, "%motivated%"}, {:name, "Joe%"}]
}

FlexQuery.filter(Employee, conditions) # this returns an %Ecto.Query
```
