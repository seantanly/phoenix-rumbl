defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth

  setup _context do
    conn = conn
    |> bypass_through(Rumbl.Router, :browser)
    |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halt when NO current_user exists", %{conn: conn} do
    refute conn.halted

    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when current_user exists", %{conn: conn} do
    refute conn.halted

    conn = conn
    |> assign(:current_user, %Rumbl.User{})
    |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login_user puts user_id in session", %{conn: conn} do
    user = insert_user
    refute get_session(conn, :user_id)

    conn = Auth.login_user(conn, user)
    |> send_resp(:ok, "")
    |> get("/")

    assert get_session(conn, :user_id) == user.id
  end

  test "logout_user removes user_id in session", %{conn: conn} do
    conn = put_session(conn, :user_id, 123)
    assert get_session(conn, :user_id) == 123

    conn = Auth.logout_user(conn)
    |> send_resp(:ok, "")
    |> get("/")

    refute get_session(conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user
    conn = put_session(conn, :user_id, user.id)
    refute conn.assigns[:current_user]

    conn = Auth.call(conn, Rumbl.Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no user in session sets assigns user to nil", %{conn: conn} do
    refute conn.assigns[:current_user]
    refute get_session(conn, :user_id)

    conn = Auth.call(conn, Rumbl.Repo)

    refute conn.assigns[:current_user]
  end

  test "login_by_user_password with valid username and password logs in user", %{conn: conn} do
    user = insert_user(%{username: "max", password: "secret"})

    {:ok, conn} = Auth.login_by_user_password(conn, "max", "secret", Rumbl.Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "login_by_user_password with invalid username does not login user", %{conn: conn} do
    {:error, :not_found, conn} = Auth.login_by_user_password(conn, "blah", "blah", Rumbl.Repo)

    refute conn.assigns[:current_user]
  end

  test "login_by_user_password with valid username but wrong password does not login user", %{conn: conn} do
    insert_user(%{username: "max", password: "secret"})

    {:error, :unauthorized, conn} = Auth.login_by_user_password(conn, "max", "blah", Rumbl.Repo)

    refute conn.assigns[:current_user]
  end
end
