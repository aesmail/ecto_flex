defmodule EctoFlexTest.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias EctoFlex.Repo
      alias EctoFlex.Schemas.{User, Hobby}
      import Ecto
      import Ecto.Query
      import EctoFlexTest.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoFlex.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoFlex.Repo, {:shared, self()})
    end

    :ok
  end
end
