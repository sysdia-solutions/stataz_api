defmodule StatazApi.UserControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.User
  @default_user %User{username: "luke.skywalker", password_hash: "rebellion", email: "luke@skywalker.com"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)
    conn = get(conn, user_path(conn, :show, user_luke.username))
    assert json_response(conn, 200)["data"] == %{"id" => user_luke.id,
                                                 "username" => user_luke.username,
                                                 "email" => user_luke.email}
  end

  test "does not show resource and instead throw error when username is nonexistent", %{conn: conn} do
    conn = get(conn, user_path(conn, :show, "darth.maul"))
    assert json_response(conn, 404) == %{"errors" => %{"title" => "User 'darth.maul' can't be found"}}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    create_attrs = %{username: "han.solo", password: "smuggler", email: "han@solo.com"}
    post(conn, user_path(conn, :create), create_attrs)
    assert Repo.get_by(User, %{username: "han.solo"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), @invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
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
    put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash != user_luke.password_hash
    assert updated_user.email == "leia@organa.com"
  end

  test "updates email only and renders chosen resource when data is valid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{email: "leia@organa.com"}
    put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash == user_luke.password_hash
    assert updated_user.email == "leia@organa.com"
  end

  test "updates password only and renders chosen resource when data is valid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "princess"}
    put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    updated_user = Repo.get_by(User, %{username: "luke.skywalker"})

    assert updated_user.password_hash != user_luke.password_hash
    assert updated_user.email == "luke@skywalker.com"
  end

  test "does not update chosen resource and renders errors when email is not unique", %{conn: conn} do
    Repo.insert!(@default_user)
    user_han = Repo.insert! %User{username: "han.solo", password_hash: "smuggler", email: "han@solo.com"}

    update_attrs = %{password: "smuggler", email: "luke@skywalker.com"}
    conn = put(conn, user_path(conn, :update, user_han.username), update_attrs)

    assert json_response(conn, 422)["errors"] == %{"email" => ["has already been taken"]}
  end

  test "does not update chosen resource and renders errors when username is updated", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "rebellion", username: "darth.luke"}
    conn = put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    assert json_response(conn, 422)["errors"] == %{"username" => ["can't be changed"]}
  end

  test "does not update resource and instead throw error when username is nonexistent", %{conn: conn} do
    conn = get(conn, user_path(conn, :update, "darth.maul"))
    assert json_response(conn, 404) == %{"errors" => %{"title" => "User 'darth.maul' can't be found"}}
  end

  test "does not update resource and renders errors when email is invalid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{email: "luke"}
    conn = put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    assert json_response(conn, 422)["errors"] == %{"email" => ["has invalid format"]}
  end

  test "does not update resource and renders errors when password is invalid", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)

    update_attrs = %{password: "rebel"}
    conn = put(conn, user_path(conn, :update, user_luke.username), update_attrs)
    assert json_response(conn, 422)["errors"] == %{"password" => ["should be at least 8 character(s)"]}
  end

  test "deletes chosen resource", %{conn: conn} do
    user_luke = Repo.insert!(@default_user)
    conn = delete(conn, user_path(conn, :delete, user_luke.username))
    assert response(conn, 204)
    refute Repo.get(User, user_luke.id)
  end

  test "does not delete resource and instead throw error when username is nonexistent", %{conn: conn} do
    conn = get(conn, user_path(conn, :delete, "darth.maul"))
    assert json_response(conn, 404) == %{"errors" => %{"title" => "User 'darth.maul' can't be found"}}
  end
end
