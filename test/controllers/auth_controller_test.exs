defmodule StatazApi.AuthControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.AccessToken

  @default_user %{username: "luke.skywalker", password: "rebellion", email: "luke@skywalker.com"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = "tyidirium"
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = post(conn, auth_path(conn, :create), %{username: @default_user.username, password: @default_user.password})

    assert json_response(conn, 201)["data"]["token_type"] == "bearer"
    assert json_response(conn, 201)["data"]["expires_in"] == 3600
    assert json_response(conn, 201)["data"]["access_token"] |> String.length == 64
  end

  test "does not create resource and returns error when resource not found", %{conn: conn} do
    conn = post(conn, auth_path(conn, :create), %{username: "darth.maul", password: "non-existent-sith"})
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "does not create resource and returns error when credentials are invalid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = post(conn, auth_path(conn, :create), %{username: @default_user.username, password: "sith-hacker"})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "shows chosen resource when authenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = get(conn, auth_path(conn, :show))

    assert json_response(conn, 200)["data"]["token_type"] == "bearer"
    assert json_response(conn, 200)["data"]["expires_in"] == 3600
    assert json_response(conn, 200)["data"]["access_token"] |> String.length == 9
  end

  test "does not show resource when unauthenticated", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = get(conn, auth_path(conn, :show))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not show resource when token expires", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 0)
    conn = get(conn, auth_path(conn, :show))

    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "deletes the resource when authenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, auth_path(conn, :delete))

    assert response(conn, 204)
    refute Repo.get_by(AccessToken, user_id: user_luke.id)
  end

  test "does not delete resource when unauthenticated", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = delete(conn, auth_path(conn, :delete))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end
end
