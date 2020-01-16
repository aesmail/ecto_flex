defmodule EctoFlexTest do
  use ExUnit.Case
  use EctoFlexTest.RepoCase
  alias EctoFlex.FlexQuery
  alias EctoFlex
  doctest EctoFlex

  defp insert_user(params) do
    user_params =
      %{
        "name" => "John",
        "age" => "39",
        "birthdate" => ~D[1980-04-01],
        "alive" => true,
        "description" => "very motivated and willing to learn",
        "gender" => "m",
        "status" => "married"
      }
      |> Map.merge(params)

    %User{}
    |> User.changeset(user_params)
    |> Repo.insert()
  end

  defp insert_hobby(params \\ %{}) do
    hobby_params = %{"name" => "Soccer"} |> Map.merge(params)
    Hobby.changeset(%Hobby{}, hobby_params) |> Repo.insert()
  end

  defp create_data() do
    {:ok, soccer} = insert_hobby()
    {:ok, movies} = insert_hobby(%{"name" => "Movies"})
    {:ok, _swimming} = insert_hobby(%{"name" => "Swimming"})

    {:ok, _user1} = insert_user(%{"hobby_id" => soccer.id})

    {:ok, _user2} =
      insert_user(%{
        "gender" => "f",
        "status" => "single",
        "name" => "Christina",
        "age" => 25,
        "hobby_id" => movies.id
      })

    {:ok, _user3} = insert_user(%{"name" => "Christ", "age" => 19, "hobby_id" => soccer.id})

    {:ok, _user4} =
      insert_user(%{"name" => "Brian", "age" => 54, "hobby_id" => soccer.id, "description" => nil})
  end

  test "building a simple query" do
    create_data()

    conditions = %{
      "age" => %{"is" => [38, 39, 40]},
      "name" => %{"contains" => "John"},
      "status" => %{"is" => "married"}
    }

    result =
      User
      |> FlexQuery.filter(conditions)
      |> Repo.all()

    assert length(result) == 1

    conditions = %{
      "name" => %{"contains" => "Chris"}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 2

    conditions = %{
      "name" => %{"contains" => "tina"}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 1

    conditions = %{
      "age" => %{"less_than" => 20}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 1

    conditions = %{
      "description" => %{"is" => nil}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 1

    conditions = %{
      "description" => %{"not" => nil}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 3
  end

  test "associations" do
    create_data()

    conditions = %{
      "name" => %{"contains" => "Chris"},
      "@hobby" => %{"name" => %{"is" => "Soccer"}}
    }

    result = FlexQuery.filter(User, conditions) |> Repo.all()
    assert length(result) == 1
    christ = Enum.at(result, 0)
    assert christ.age == 19
  end
end
