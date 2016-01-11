defmodule StatazApi.UserControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.User

  @default_user %User{username: "luke.skywalker", password_hash: "rebellion", email: "luke@skywalker.com"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = "tyidirium"
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  test "shows chosen resource", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = get(conn, user_path(conn, :show))
    assert json_response(conn, 200)["data"] == %{"id" => user_luke.id,
                                                 "username" => user_luke.username,
                                                 "email" => user_luke.email}
  end

  test "does not show resource when unauthenticated", %{conn: conn} do
    Repo.insert!(@default_user)
    conn = get(conn, user_path(conn, :show))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not show resource when token expires", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)
    conn = authenticate(conn, Repo, user_luke.id, 0)
    conn = get(conn, user_path(conn, :show))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    create_attrs = %{username: "han.solo", password: "smuggler", email: "han@solo.com"}
    post(conn, user_path(conn, :create), create_attrs)
    assert Repo.get_by(User, %{username: "han.solo"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), @invalid_attrs)
    assert json_response(conn, 422)["errors"] == %{"email" => ["can't be blank"], "password" => ["can't be blank"], "username" => ["can't be blank"]}
  end

  test "does not create resource and renders errors when username is invalid", %{conn: conn} do
    create_attrs = %{username: "R2", password: "astrodroid", email: "r2@d2.com"}
    conn = post(conn, user_path(conn, :create), create_attrs)
    assert json_response(conn, 422)["errors"] == %{"username" => ["should be at least 3 character(s)"]}
  end

  test "does not create resource and renders errors when email is invalid", %{conn: conn} do
    create_attrs = %{username: "han.solo", password: "smuggler", email: "han"}
    conn = post(conn, user_path(conn, :create), create_attrs)
    assert json_response(conn, 422)["errors"] == %{"email" => ["has invalid format"]}
  end

  test "does not create resource and renders errors when password is invalid", %{conn: conn} do
    create_attrs = %{username: "han.solo", password: "han", email: "han@solo.com"}
    conn = post(conn, user_path(conn, :create), create_attrs)
    assert json_response(conn, 422)["errors"] == %{"password" => ["should be at least 8 character(s)"]}
  end

  test "does not create resource and renders errors when email is not unique", %{conn: conn} do
    Repo.insert!(@default_user)

    create_attrs = %{username: "han.solo", password: "smuggler", email: "luke@skywalker.com"}
    conn = post(conn, user_path(conn, :create), create_attrs)
    assert json_response(conn, 422)["errors"] == %{"email" => ["has already been taken"]}
  end

  test "does not create resource and renders errors when username is not unique", %{conn: conn} do
    Repo.insert!(@default_user)

    create_attrs = %{username: "luke.skywalker", password: "smuggler", email: "han@solo.com"}
    conn = post(conn, user_path(conn, :create), create_attrs)
    assert json_response(conn, 422)["errors"] == %{"username" => ["has already been taken"]}
  end

  test "updates email, password and renders chosen resource when data is valid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "princess", email: "leia@organa.com"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    put(conn, user_path(conn, :update), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash != user_luke.password_hash
    assert updated_user.email == "leia@organa.com"
  end

  test "updates email only and renders chosen resource when data is valid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{email: "leia@organa.com"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    put(conn, user_path(conn, :update), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash == user_luke.password_hash
    assert updated_user.email == "leia@organa.com"
  end

  test "updates password only and renders chosen resource when data is valid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "princess"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    put(conn, user_path(conn, :update), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash != user_luke.password_hash
    assert updated_user.email == "luke@skywalker.com"
  end

  test "does not update chosen resource and renders errors when email is not unique", %{conn: conn} do
    Repo.insert!(@default_user)
    user_han = Repo.insert! %User{username: "han.solo", password_hash: "smuggler", email: "han@solo.com"}

    update_attrs = %{password: "smuggler", email: "luke@skywalker.com"}
    conn = authenticate(conn, Repo, user_han.id, 3600)
    conn = put(conn, user_path(conn, :update), update_attrs)

    assert json_response(conn, 422)["errors"] == %{"email" => ["has already been taken"]}
  end

  test "does not update chosen resource and renders errors when username is updated", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "rebellion", username: "darth.luke"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, user_path(conn, :update), update_attrs)
    assert json_response(conn, 422)["errors"] == %{"username" => ["can't be changed"]}
  end

  test "does not update resource and renders errors when email is invalid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{email: "luke"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, user_path(conn, :update), update_attrs)
    assert json_response(conn, 422)["errors"] == %{"email" => ["has invalid format"]}
  end

  test "does not update resource and renders errors when password is invalid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "rebel"}
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, user_path(conn, :update), update_attrs)

    assert json_response(conn, 422)["errors"] == %{"password" => ["should be at least 8 character(s)"]}
  end

  test "deletes chosen resource", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, user_path(conn, :delete))
    assert response(conn, 204)
    refute Repo.get(User, user_luke.id)
  end
end
