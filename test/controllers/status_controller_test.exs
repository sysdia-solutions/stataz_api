defmodule StatazApi.StatusControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.Status

  @default_user %{username: "luke.skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @status_1 %{description: "fighting", active: false}
  @status_2 %{description: "battling", active: true}
  @status_3 %{description: "training", active: false}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = "tyidirium"
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  test "lists all resources for authenticated user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    status_3 = TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = get(conn, status_path(conn, :list))

    expected = [
                 %{
                   "id" => status_1.id,
                   "description" => @status_1.description,
                   "active" => @status_1.active
                 },
                 %{
                   "id" => status_2.id,
                   "description" => @status_2.description,
                   "active" => @status_2.active
                 },
                 %{
                   "id" => status_3.id,
                   "description" => @status_3.description,
                   "active" => @status_3.active
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "displays an empty list when no resources exist for authenticated user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = get(conn, status_path(conn, :list))

    assert json_response(conn, 200)["data"] == []
  end

  test "does not list resources when unauthenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.create_status(Repo, user_luke.id, "flying", false)

    conn = get(conn, status_path(conn, :list))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, status_path(conn, :create), @status_1)

    status_1 = Repo.get_by(Status, %{description: @status_1.description})

    assert status_1
    assert json_response(conn, 201)["data"] == %{"id" => status_1.id,
                                                "description" => @status_1.description,
                                                "active" => false
                                               }
  end

  test "creates resource and always set active to false", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, status_path(conn, :create), @status_2)

    status_2 = Repo.get_by(Status, %{description: @status_2.description})

    assert status_2
    assert json_response(conn, 201)["data"] == %{"id" => status_2.id,
                                                "description" => @status_2.description,
                                                "active" => false
                                               }
  end

  test "does not create resource and renders errors when data is invald", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, status_path(conn, :create), @invalid_attrs)
    assert json_response(conn, 422)["errors"] == %{"description" => ["can't be blank"]}
  end

  test "does not create resource and renders errors when description is too short", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, status_path(conn, :create), %{description: "a"})
    assert json_response(conn, 422)["errors"] == %{"description" => ["should be at least 2 character(s)"]}
  end

  test "does not create resource and renders errors when description is too long", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, status_path(conn, :create), %{description: "having a battle in a galaxy, far far away"})
    assert json_response(conn, 422)["errors"] == %{"description" => ["should be at most 32 character(s)"]}
  end

  test "updates resource description and renders resource when data is valid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, status_1.id), %{description: "dueling"})

    assert json_response(conn, 200)["data"] == %{"id" => status_1.id,
                                                "description" => "dueling",
                                                "active" => @status_1.active
                                               }
  end

  test "updates active:true resource description and renders resource when data is valid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, status_2.id), %{description: "spying"})

    assert json_response(conn, 200)["data"] == %{"id" => status_2.id,
                                                "description" => "spying",
                                                "active" => @status_2.active
                                               }
  end

  test "updates previous active:true resource to active:false when new active:true resource is set", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)

    assert status_1.active == false
    assert status_2.active == true

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, status_1.id), %{active: true})

    status_2 = Repo.get(Status, status_2.id)

    assert json_response(conn, 200)["data"] == %{"id" => status_1.id,
                                                "description" => @status_1.description,
                                                "active" => true
                                               }
    assert status_2.active == false
  end

  test "does not update a resource with active:true to become active:false", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, status_2.id), %{active: false})

    assert json_response(conn, 403)["errors"]["title"] == "Forbidden"
  end

  test "does not update description and renders error when the data is invalid", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, status_1.id), %{description: "a"})

    assert json_response(conn, 422)["errors"] ==  %{"description" => ["should be at least 2 character(s)"]}
  end

  test "does not update resource when unauthenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)

    conn = put(conn, status_path(conn, :update, status_1.id), %{description: "dueling"})
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not update resource when non-existent", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = put(conn, status_path(conn, :update, 1), %{description: "dueling"})
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "deletes chosen resource", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, status_path(conn, :delete, status_1.id))

    assert response(conn, 204)
    refute Repo.get(Status, status_1.id)
  end

  test "does not delete resource when unauthenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    conn = delete(conn, status_path(conn, :delete, status_1.id))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "does not delete resource when non-existent", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, status_path(conn, :delete, 1))
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "does not delete resource when active is true", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, status_path(conn, :delete, status_2.id))

    assert json_response(conn, 403)["errors"]["title"] == "Forbidden"
  end
end
