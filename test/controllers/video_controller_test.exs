defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.Video
  @valid_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @invalid_attrs %{title: "invalid"}

  def video_count(query), do: Repo.one(from v in query, select: count(v.id))

  setup %{conn: conn}=context do
    # IO.inspect context
    if username = context[:login_as] do
      user = insert_user(%{username: username})
      conn = assign(conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      put(conn, video_path(conn, :update, "123", %{})),
      post(conn, video_path(conn, :create, %{})),
      delete(conn, video_path(conn, :delete, "123")),
    ], fn conn ->
      # IO.inspect conn
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "Lists all videos of logged in user on index", %{conn: conn, user: user} do
    user_video = insert_video(user, %{title: "funny cats"})
    other_video = insert_video(insert_user(%{username: "other"}), %{title: "another video"})

    conn = get(conn, video_path(conn, :index))
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert conn.resp_body |> String.contains?(user_video.title)
    refute conn.resp_body |> String.contains?(other_video.title)
  end

  @tag login_as: "max"
  test "does not create video and renders errors when invalid", %{conn: conn} do
    count_before = video_count(Video)
    conn = post(conn, video_path(conn, :create), video: @invalid_attrs)
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  @tag login_as: "max"
  test "authorization blocks access by other users", %{conn: conn, user: owner} do
    video = insert_video(owner, @valid_attrs)
    non_owner = insert_user(%{username: "sneaky"})
    conn = assign(conn, :current_user, non_owner)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, video_path(conn, :show, video))
    end

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, video_path(conn, :edit, video))
    end

    assert_raise Ecto.NoResultsError, fn ->
      put(conn, video_path(conn, :update, video, video: @valid_attrs))
    end

    assert_raise Ecto.NoResultsError, fn ->
      delete(conn, video_path(conn, :delete, video))
    end
  end

end
