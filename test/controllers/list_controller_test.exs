defmodule StatazApi.ListControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon

  @default_user %{username: "luke_skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @status_1 %{description: "fighting", active: false}
  @status_2 %{description: "battling", active: true}
  @status_3 %{description: "training", active: false}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all users in newest user first order", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com", 1)
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com", 2)
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com", 3)

    # Previously active statuses should not cause user duplicates
    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active, true)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active, true)

    luke_active_status = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    han_active_status = TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    vader_active_status = TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :new_users))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(vader_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_vader.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(leia_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_leia.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(han_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_han.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(luke_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_luke.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists subset of users in newest user first order given limit/offset", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com", 1)
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com", 2)
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com", 3)

    TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)
    han_active_status = TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :new_users, limit: 2, offset: 1))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(leia_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_leia.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(han_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_han.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists all users in newest active status first order", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com", 1)
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com", 2)
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com", 3)

    # Previously active statuses should not cause user duplicates
    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active, true)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active, true)

    han_active_status = TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    vader_active_status = TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    luke_active_status = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :new_statuses))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(luke_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_luke.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(leia_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_leia.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(vader_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_vader.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(han_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_han.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists subset of users in newest active status first order given limit/offset", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com", 1)
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com", 2)
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com", 3)

    TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    vader_active_status = TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :new_statuses, limit: 2, offset: 1))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(leia_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_leia.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(vader_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_vader.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists all statuses by most popular first order", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")
    user_r2d2 = TestCommon.create_user(Repo, "r2_d2", "astrodroid", "r2@d2.com")
    user_c3po = TestCommon.create_user(Repo, "c_3po", "interpreter", "c@3po.com")
    user_lando = TestCommon.create_user(Repo, "lando_calrissian", "smoothtalker", "lando@calrissian.com")

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_han.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_han.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_leia.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_leia.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_vader.id, @status_2.description, false)
    TestCommon.create_status(Repo, user_vader.id, @status_3.description, true)

    TestCommon.create_status(Repo, user_r2d2.id, @status_2.description, false)
    TestCommon.create_status(Repo, user_r2d2.id, @status_3.description, true)

    TestCommon.create_status(Repo, user_c3po.id, @status_1.description, true)

    TestCommon.create_status(Repo, user_lando.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :popular_statuses))

    expected = [
                 %{
                   "status" => @status_2.description,
                   "count" => 4
                 },
                 %{
                   "status" => @status_3.description,
                   "count" => 2
                 },
                 %{
                   "status" => @status_1.description,
                   "count" => 1
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists subset of statuses by most popular first order given limit/offset", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "princess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")
    user_r2d2 = TestCommon.create_user(Repo, "r2_d2", "astrodroid", "r2@d2.com")
    user_c3po = TestCommon.create_user(Repo, "c_3po", "interpreter", "c@3po.com")
    user_lando = TestCommon.create_user(Repo, "lando_calrissian", "smoothtalker", "lando@calrissian.com")

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_han.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_han.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_leia.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_leia.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_vader.id, @status_2.description, false)
    TestCommon.create_status(Repo, user_vader.id, @status_3.description, true)

    TestCommon.create_status(Repo, user_r2d2.id, @status_2.description, false)
    TestCommon.create_status(Repo, user_r2d2.id, @status_3.description, true)

    TestCommon.create_status(Repo, user_c3po.id, @status_1.description, true)

    TestCommon.create_status(Repo, user_lando.id, @status_2.description, @status_2.active)

    conn = get(conn, list_path(conn, :popular_statuses, limit: 1, offset: 1))

    expected = [
                 %{
                   "status" => @status_3.description,
                   "count" => 2
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end
end
