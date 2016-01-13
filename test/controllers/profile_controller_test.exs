defmodule StatazApi.ProfileControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon

  @default_user %{username: "luke.skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @status_1 %{description: "fighting", active: false}
  @status_2 %{description: "battling", active: true}
  @status_3 %{description: "training", active: false}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = "tyidirium"
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  defp get_response_field(conn, index, field) do
    {:ok, data} = conn.resp_body
                  |> Poison.decode()
    Enum.at(data["data"], index)[field]
  end

  test "show resource and render for valid user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    conn = get(conn, profile_path(conn, :show, user_luke.username))

    assert json_response(conn, 200)["data"] == [%{"username" => @default_user.username,
                                                 "status" => @status_2.description,
                                                 "since" => TestCommon.date_to_json(status_2.updated_at)}]
  end

  test "show resource and render multiple statuses for each history", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    status_3 = TestCommon.create_status(Repo, user_luke.id, @status_3.description, true)

    conn = get(conn, profile_path(conn, :show, user_luke.username))

    assert json_response(conn, 200)["data"] == [
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_3.description,
                                                   "since" => TestCommon.date_to_json(status_3.updated_at)},
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_2.description,
                                                   "since" => TestCommon.date_to_json(status_2.updated_at)}
                                               ]

  end

  test "show resource and render multiple statuses limtied to 5 for different history changes via status controller", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    status_1 = TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    status_3 = TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    put(conn, status_path(conn, :update, status_1.id), %{active: true})
    put(conn, status_path(conn, :update, status_3.id), %{active: true})
    put(conn, status_path(conn, :update, status_2.id), %{active: true})
    put(conn, status_path(conn, :update, status_1.id), %{active: true})
    put(conn, status_path(conn, :update, status_3.id), %{active: true})

    conn = get(conn, profile_path(conn, :show, user_luke.username))

    assert json_response(conn, 200)["data"] == [
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_3.description,
                                                   "since" => get_response_field(conn, 4, "since")},
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_1.description,
                                                   "since" => get_response_field(conn, 3, "since")},
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_2.description,
                                                   "since" => get_response_field(conn, 2, "since")},
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_3.description,
                                                   "since" => get_response_field(conn, 1, "since")},
                                                 %{"username" => @default_user.username,
                                                   "status" => @status_1.description,
                                                   "since" => get_response_field(conn, 0, "since")}
                                               ]
  end

  test "does not show resource and renders errors when user not found", %{conn: conn} do
    conn = get(conn, profile_path(conn, :show, "darth.maul"))
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end
end
