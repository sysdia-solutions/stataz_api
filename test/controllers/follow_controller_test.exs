defmodule StatazApi.FollowControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon
  alias StatazApi.Follow

  @user_luke %{username: "luke_skywalker", password: "rebellion", email: "luke@skywalker.com", status: "dueling"}
  @user_han %{username: "han_solo", password: "scoundrel", email: "han@solo.com", status: "smuggling"}
  @user_leia %{username: "leia_organa", password: "princess", email: "leia@organa.com", status: "debating"}
  @user_r2d2 %{username: "r2_d2", password: "astrodroid", email: "r2@d2.com", status: "hacking"}
  @user_c3po %{username: "c_3po", password: "protocoldroid", email: "c@3po.com", status: "interpreting"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn, repo, user_id, expiry_seconds) do
    token = "tyidirium"
    TestCommon.build_token(repo, user_id, token, expiry_seconds)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  test "creates resource for valid follow request", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, follow_path(conn, :create, @user_han.username))

    assert json_response(conn, 201)["data"] == ""
    assert Repo.get_by(Follow, %{follower_id: user_luke.id, following_id: user_han.id})
  end

  test "does not create resource and renders errors when unauthenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    conn = post(conn, follow_path(conn, :create, @user_han.username))

    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
    refute Repo.get_by(Follow, %{follower_id: user_luke.id, following_id: user_han.id})
  end

  test "does not create resource and renders errors when already following user", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    TestCommon.create_follow(user_luke.id, user_han.id, Repo)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, follow_path(conn, :create, @user_han.username))

    assert json_response(conn, 403)["errors"]["title"] == "Forbidden"
  end

  test "does not create resource and renders errors when attempt to follow self", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, follow_path(conn, :create, @user_luke.username))

    assert json_response(conn, 422)["errors"] == %{"following_id" => ["can't be the same"]}
    refute Repo.get_by(Follow, %{follower_id: user_luke.id, following_id: user_luke.id})
  end

  test "does not create resource and renders errors when other user is non-existent", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = post(conn, follow_path(conn, :create, @user_han.username))

    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "deletes chosen resource", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    TestCommon.create_follow(user_luke.id, user_han.id, Repo)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, follow_path(conn, :delete, @user_han.username))

    assert response(conn, 204)
    refute Repo.get_by(Follow, %{follower_id: user_luke.id, following_id: user_han.id})
  end

  test "does not delete resource if unauthenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    TestCommon.create_follow(user_luke.id, user_han.id, Repo)

    conn = delete(conn, follow_path(conn, :delete, @user_han.username))

    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
    assert Repo.get_by(Follow, %{follower_id: user_luke.id, following_id: user_han.id})
  end

  test "does not delete resource if not following", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, follow_path(conn, :delete, @user_han.username))

    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "does not delete resource when other user is non-existent", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = delete(conn, follow_path(conn, :delete, @user_han.username))

    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end

  test "shows authenticated user's follower/following list", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)
    user_leia = TestCommon.create_user(Repo, @user_leia.username, @user_leia.password, @user_leia.email)
    user_r2d2 = TestCommon.create_user(Repo, @user_r2d2.username, @user_r2d2.password, @user_r2d2.email)
    user_c3po = TestCommon.create_user(Repo, @user_c3po.username, @user_c3po.password, @user_c3po.email)

    TestCommon.create_status(Repo, user_luke.id, @user_luke.status, true)
    TestCommon.create_status(Repo, user_han.id, @user_han.status, true)
    TestCommon.create_status(Repo, user_leia.id, @user_leia.status, true)
    TestCommon.create_status(Repo, user_r2d2.id, @user_r2d2.status, true)
    TestCommon.create_status(Repo, user_c3po.id, @user_c3po.status, true)

    luke_follows_han = TestCommon.create_follow(user_luke.id, user_han.id, Repo)
    luke_follows_leia = TestCommon.create_follow(user_luke.id, user_leia.id, Repo)
    han_follows_luke = TestCommon.create_follow(user_han.id, user_luke.id, Repo)
    r2d2_follows_luke = TestCommon.create_follow(user_r2d2.id, user_luke.id, Repo)
    c3po_follows_luke = TestCommon.create_follow(user_c3po.id, user_luke.id, Repo)

    conn = authenticate(conn, Repo, user_luke.id, 3600)
    conn = get(conn, follow_path(conn, :show))

    expected =  %{
                  "following" =>
                    [
                      %{"username" => @user_leia.username,
                        "since" => TestCommon.date_to_json(luke_follows_leia.inserted_at),
                        "status" => @user_leia.status
                      },
                      %{"username" => @user_han.username,
                        "since" => TestCommon.date_to_json(luke_follows_han.inserted_at),
                        "status" => @user_han.status
                      }
                    ],
                  "followers" =>
                    [
                      %{"username" => @user_c3po.username,
                        "since" => TestCommon.date_to_json(c3po_follows_luke.inserted_at),
                        "status" => @user_c3po.status
                      },
                      %{"username" => @user_r2d2.username,
                        "since" => TestCommon.date_to_json(r2d2_follows_luke.inserted_at),
                        "status" => @user_r2d2.status
                      },
                      %{"username" => @user_han.username,
                        "since" => TestCommon.date_to_json(han_follows_luke.inserted_at),
                        "status" => @user_han.status
                      }
                    ]
                }

    assert json_response(conn, 200)["data"] == expected
  end

  test "does now show user's follower/following list if not authenticated", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)
    user_leia = TestCommon.create_user(Repo, @user_leia.username, @user_leia.password, @user_leia.email)
    user_r2d2 = TestCommon.create_user(Repo, @user_r2d2.username, @user_r2d2.password, @user_r2d2.email)
    user_c3po = TestCommon.create_user(Repo, @user_c3po.username, @user_c3po.password, @user_c3po.email)

    TestCommon.create_follow(user_luke.id, user_han.id, Repo)
    TestCommon.create_follow(user_luke.id, user_leia.id, Repo)
    TestCommon.create_follow(user_han.id, user_luke.id, Repo)
    TestCommon.create_follow(user_r2d2.id, user_luke.id, Repo)
    TestCommon.create_follow(user_c3po.id, user_luke.id, Repo)

    conn = get(conn, follow_path(conn, :show))
    assert json_response(conn, 401)["errors"]["title"] == "Authentication failed"
  end

  test "shows public follower/following list without authentication requirement", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @user_luke.username, @user_luke.password, @user_luke.email)
    user_han = TestCommon.create_user(Repo, @user_han.username, @user_han.password, @user_han.email)
    user_leia = TestCommon.create_user(Repo, @user_leia.username, @user_leia.password, @user_leia.email)
    user_r2d2 = TestCommon.create_user(Repo, @user_r2d2.username, @user_r2d2.password, @user_r2d2.email)
    user_c3po = TestCommon.create_user(Repo, @user_c3po.username, @user_c3po.password, @user_c3po.email)

    TestCommon.create_status(Repo, user_luke.id, @user_luke.status, true)
    TestCommon.create_status(Repo, user_han.id, @user_han.status, true)
    TestCommon.create_status(Repo, user_leia.id, @user_leia.status, true)
    TestCommon.create_status(Repo, user_r2d2.id, @user_r2d2.status, true)
    TestCommon.create_status(Repo, user_c3po.id, @user_c3po.status, true)

    luke_follows_han = TestCommon.create_follow(user_luke.id, user_han.id, Repo)
    luke_follows_leia = TestCommon.create_follow(user_luke.id, user_leia.id, Repo)
    han_follows_luke = TestCommon.create_follow(user_han.id, user_luke.id, Repo)
    r2d2_follows_luke = TestCommon.create_follow(user_r2d2.id, user_luke.id, Repo)
    c3po_follows_luke = TestCommon.create_follow(user_c3po.id, user_luke.id, Repo)

    conn = get(conn, follow_path(conn, :public_show, @user_luke.username))

    expected =  %{
                  "following" =>
                    [
                      %{"username" => @user_leia.username,
                        "since" => TestCommon.date_to_json(luke_follows_leia.inserted_at),
                        "status" => @user_leia.status
                      },
                      %{"username" => @user_han.username,
                        "since" => TestCommon.date_to_json(luke_follows_han.inserted_at),
                        "status" => @user_han.status
                      }
                    ],
                  "followers" =>
                    [
                      %{"username" => @user_c3po.username,
                        "since" => TestCommon.date_to_json(c3po_follows_luke.inserted_at),
                        "status" => @user_c3po.status
                      },
                      %{"username" => @user_r2d2.username,
                        "since" => TestCommon.date_to_json(r2d2_follows_luke.inserted_at),
                        "status" => @user_r2d2.status
                      },
                      %{"username" => @user_han.username,
                        "since" => TestCommon.date_to_json(han_follows_luke.inserted_at),
                        "status" => @user_han.status
                      }
                    ]
                }

    assert json_response(conn, 200)["data"] == expected
  end

  test "does not show public follower/following list for non-existent user", %{conn: conn} do
    conn = get(conn, follow_path(conn, :public_show, "darth.maul"))
    assert json_response(conn, 404)["errors"]["title"] == "Resource can't be found"
  end
end
