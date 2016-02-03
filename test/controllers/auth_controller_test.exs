defmodule StatazApi.AuthControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.AccessToken
  alias StatazApi.RefreshToken

  @default_user %{username: "luke_skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @invalid_attrs %{}
  @default_token "tyidirium"
  @default_client_id "deathstar"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = @default_token
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    TestCommon.build_refresh_token(repo, user_id, token, @default_client_id)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  test "creates and renders resource for `grant_type: password` when data is valid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    params = %{grant_type: "password",
               username: @default_user.username,
               password: @default_user.password,
               client_id: @default_client_id}

    conn = post(conn, auth_path(conn, :create), params)

    assert json_response(conn, 201)["data"]["token_type"] == "bearer"
    assert json_response(conn, 201)["data"]["expires_in"] >= 3590
    assert json_response(conn, 201)["data"]["access_token"] |> String.length == 128
    assert json_response(conn, 201)["data"]["refresh_token"] |> String.length == 128
  end

  test "creates and renders resource for `grant_type: password` without refresh_token when data is valid but missing client_id", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    params = %{grant_type: "password",
               username: @default_user.username,
               password: @default_user.password}

    conn = post(conn, auth_path(conn, :create), params)

    assert json_response(conn, 201)["data"]["token_type"] == "bearer"
    assert json_response(conn, 201)["data"]["expires_in"] >= 3590
    assert json_response(conn, 201)["data"]["access_token"] |> String.length == 128
    assert json_response(conn, 201)["data"]["refresh_token"] |> String.length == 0
  end

  test "creates and renders resource for `grant_type: password` without refresh_token when data is valid but client_id is invalid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    params = %{grant_type: "password",
               username: @default_user.username,
               password: @default_user.password,
               client_id: "yavin4"}

    conn = post(conn, auth_path(conn, :create), params)

    assert json_response(conn, 201)["data"]["token_type"] == "bearer"
    assert json_response(conn, 201)["data"]["expires_in"] >= 3590
    assert json_response(conn, 201)["data"]["access_token"] |> String.length == 128
    assert json_response(conn, 201)["data"]["refresh_token"] |> String.length == 0
  end

  test "creates and renders resource for `grant_type: refresh_token` when data is valid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.build_refresh_token(Repo, user_luke.id, @default_token, @default_client_id)

    params = %{grant_type: "refresh_token",
               refresh_token: @default_token,
               client_id: @default_client_id}

    conn = post(conn, auth_path(conn, :create), params)

    assert json_response(conn, 201)["data"]["token_type"] == "bearer"
    assert json_response(conn, 201)["data"]["expires_in"] >= 3590
    assert json_response(conn, 201)["data"]["access_token"] |> String.length == 128
    assert json_response(conn, 201)["data"]["refresh_token"] |> String.length == 128
  end

  test "does not create resource and returns error when invalid parameters", %{conn: conn} do
    conn = post(conn, auth_path(conn, :create), @invalid_attrs)
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not create resource and returns error when resource not found", %{conn: conn} do
    conn = post(conn, auth_path(conn, :create), %{grant_type: "password", username: "darth.maul", password: "non-existent-sith"})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not create resource and returns error when credentials are invalid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = post(conn, auth_path(conn, :create), %{grant_type: "password", username: @default_user.username, password: "sith-hacker"})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not create resource and returns error when refresh_token is invalid", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = post(conn, auth_path(conn, :create), %{grant_type: "refresh_token", refresh_token: "", client_id: @default_client_id})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not create resource and returns error when refresh_token is valid but client_id is invalid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.build_refresh_token(Repo, user_luke.id, @default_token, @default_client_id)

    conn = post(conn, auth_path(conn, :create), %{grant_type: "refresh_token", refresh_token: @default_token, client_id: ""})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "deletes the access_token and refresh_token when authenticated and given client_id", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)

    assert Repo.get_by(AccessToken, user_id: user_luke.id)
    assert Repo.get_by(RefreshToken, user_id: user_luke.id)

    conn = delete(conn, auth_path(conn, :delete), %{client_id: @default_client_id})

    assert response(conn, 204)
    refute Repo.get_by(AccessToken, user_id: user_luke.id)
    refute Repo.get_by(RefreshToken, user_id: user_luke.id)
  end

  test "deletes the access_token but not refresh_token when authenticated but not given client_id", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)

    assert Repo.get_by(AccessToken, user_id: user_luke.id)
    assert Repo.get_by(RefreshToken, user_id: user_luke.id)

    conn = delete(conn, auth_path(conn, :delete))

    assert response(conn, 204)
    refute Repo.get_by(AccessToken, user_id: user_luke.id)
    assert Repo.get_by(RefreshToken, user_id: user_luke.id)
  end

  test "does not delete resource when unauthenticated", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = delete(conn, auth_path(conn, :delete))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "shows the access_token when authenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)

    conn = get(conn, auth_path(conn, :show))

    assert json_response(conn, 200)["data"]["token_type"] == "bearer"
    assert json_response(conn, 200)["data"]["expires_in"] >= 3590
    assert json_response(conn, 200)["data"]["access_token"] == @default_token
    refute json_response(conn, 200)["data"]["refresh_token"]
  end

  test "does not show the access_token when unauthenticated", %{conn: conn} do
    TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    conn = get(conn, auth_path(conn, :show))

    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end
end
