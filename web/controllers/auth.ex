defmodule Rumbl.Auth do
  import Plug.Conn
  alias Rumbl.User

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    user = conn.assigns[:current_user] || (user_id && repo.get(User, user_id))
    put_current_user(conn, user)
  end

  import Phoenix.Controller
  alias Rumbl.Router.Helpers

  def authenticate_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def login_user(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout_user(conn) do
    conn
    |> delete_session(:user_id)
    |> configure_session(renew: true)
  end

  def put_current_user(conn, nil=user), do: conn |> assign(:current_user, user)
  def put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def login_by_user_password(conn, username, password, repo) do
    user = repo.get_by(User, username: username)
    cond do
      user && check_password?(password, user.password_hash) ->
        {:ok, login_user(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_check_password # prevent timing attack that snoops username
        {:error, :not_found, conn}
    end
  end

  def check_password?(password, password_hash) do
    Comeonin.Bcrypt.checkpw(password, password_hash)
  end

  def dummy_check_password, do: Comeonin.Bcrypt.dummy_checkpw

end
