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

  test "show resource and render for valid user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    status_2 = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    conn = get(conn, profile_path(conn, :show, user_luke.username))

    {:ok, since} = status_2.updated_at
                   |> Poison.encode()
    {:ok, since} = since
                   |> Poison.decode()

    assert json_response(conn, 200)["data"] == %{"username" => @default_user.username,
                                                 "status" => @status_2.description,
                                                 "since" => since}
  end

  test "does not show resource and renders errors when user not found", %{conn: conn} do
    conn = get(conn, profile_path(conn, :show, "darth.maul"))
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end
end
