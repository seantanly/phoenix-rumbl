defmodule Rumbl.TestHelpers do

  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    changes = %{
      name: "Some User",
      username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
      password: "supersecret",
    }
    |> Map.merge(attrs)

    %Rumbl.User{}
    |> Rumbl.User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_video(user, attrs=%{}) do
    user
    |> Ecto.Model.build(:videos, attrs)
    |> Repo.insert!
  end

end
