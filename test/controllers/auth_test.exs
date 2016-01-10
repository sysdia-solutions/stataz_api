defmodule StatazApi.AuthTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.Auth

  @default_user %{username: "luke.skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @default_token "tyidirium"

  setup %{conn: conn} do
    conn = conn
           |> bypass_through(StatazApi.Router, :api)
           |> get("/")

    {:ok, %{conn: conn}}
  end

  test "call assigns current_user on conn if authenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.build_token(Repo, user_luke.id, @default_token, 3600)

    conn = put_req_header(conn, "authorization", "Bearer #{@default_token}")
    conn = Map.put(conn, :params, %{"username" => @default_user.username})

    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user.id == user_luke.id
  end

  test "call returns error and halts when unauthorized", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = Map.put(conn, :params, %{"username" => @default_user.username})
    conn = Auth.call(conn, Repo)

    assert conn.halted
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "call returns error and halts when user does not exist", %{conn: conn} do
    conn = Map.put(conn, :params, %{"username" => @default_user.username})
    conn = Auth.call(conn, Repo)
    assert conn.halted

    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "login_with_username_and_password creates an access_token and returns it" do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    {:ok, response} = Auth.login_with_username_and_password(Repo, @default_user.username, @default_user.password)

    assert response.token |> String.length() == 32
  end

  test "login_with_username_and_password returns unauthorized error with incorrect credentials" do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    response = Auth.login_with_username_and_password(Repo, @default_user.username, "sith-hacker")
    assert response == {:error, :unauthorized}
  end

  test "login_with_username_and_password returns not_found error with unknown credentials" do
    response = Auth.login_with_username_and_password(Repo, "darth.maul", "does-not-exist")
    assert response == {:error, :not_found}
  end

  test "logout deletes the user access_token and clears the current_user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.build_token(Repo, user_luke.id, @default_token, 3600)
    conn = assign(conn, :current_user, user_luke)
    conn = put_req_header(conn, "authorization", "Bearer #{@default_token}")

    assert Repo.get_by(StatazApi.AccessToken, user_id: user_luke.id)

    conn = Auth.logout(conn, Repo)

    refute Repo.get_by(StatazApi.AccessToken, user_id: user_luke.id)
    refute conn.assigns.current_user
  end

  test "logout returns unauthorized error with incorrect authorization", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = assign(conn, :current_user, user_luke)

    conn = Auth.logout(conn, Repo)

    assert conn.assigns.current_user
  end

  test "show_token returns token", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.build_token(Repo, user_luke.id, @default_token, 3600)
    conn = assign(conn, :current_user, user_luke)
    conn = put_req_header(conn, "authorization", "Bearer #{@default_token}")

    {:ok, response} = Auth.show_token(conn, Repo)

    assert response.token == @default_token
  end

  test "show_token returns unauthorized error with incorrect authorization", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = assign(conn, :current_user, user_luke)

    response = Auth.show_token(conn, Repo)
    assert response == {:error, :unauthorized}
  end

  test "show_token returns unprocessable entity without current_user", %{conn: conn} do
    response = Auth.show_token(conn, Repo)
    assert response == {:error, :unprocessable_entity}
  end
end