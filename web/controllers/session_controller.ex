defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller
  alias Rumbl.Auth
  alias Rumbl.Repo
  require Logger

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case Auth.login_by_user_password(conn, username, password, Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))
      {:error, reason, conn} ->
        Logger.debug "Login failed: #{reason}"
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout_user
    |> put_flash(:info, "You have been logged out. See you soon!")
    |> redirect(to: page_path(conn, :index))
  end

end
