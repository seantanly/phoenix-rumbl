defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.Repo
  alias Rumbl.User

  plug :authenticate_user when action in ~w(index show)a

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created")
        |> Rumbl.Auth.login_user(user)
        |> redirect(to: user_path(conn, :index))
    end

  end

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

end
