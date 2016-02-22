defmodule StatazApi.SearchControllerTest do
  use StatazApi.ConnCase

  alias StatazApi.TestCommon

  @default_user %{username: "luke_skywalker", password: "rebellion", email: "luke@skywalker.com"}
  @status_1 %{description: "fighting", active: false}
  @status_2 %{description: "battling", active: true}
  @status_3 %{description: "training", active: false}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all status results when queried by status name", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "pricess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)
    TestCommon.create_status(Repo, user_han.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_leia.id, @status_3.description, @status_3.active)

    luke_active_status = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    han_active_status = TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    vader_active_status = TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)

    conn = get(conn, search_path(conn, :list_status, @status_2.description))

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

  test "list all status results when queried by username or email", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "pricess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")
    user_anakin = TestCommon.create_user(Repo, "anakin_skywalker", "chosenone", "anakin@skywalker.com")

    # Shmi remarried and surname changed to Lars, but she never updated her email address!
    # Shmi should still show up in the search results

    user_shmi = TestCommon.create_user(Repo, "shmi_lars", "slavemother", "shmi@skywalker.com")

    TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)

    luke_active_status = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    anakin_active_status = TestCommon.create_status(Repo, user_anakin.id, @status_2.description, @status_2.active)
    shmi_active_status = TestCommon.create_status(Repo, user_shmi.id, @status_2.description, @status_2.active)

    conn = get(conn, search_path(conn, :list_user, "skywalker"))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(shmi_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_shmi.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(anakin_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_anakin.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(luke_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_luke.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

  test "lists subset of status results when queried by status name given limit/offset", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "pricess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")

    TestCommon.create_status(Repo, user_luke.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_luke.id, @status_3.description, @status_3.active)
    TestCommon.create_status(Repo, user_han.id, @status_1.description, @status_1.active)
    TestCommon.create_status(Repo, user_leia.id, @status_3.description, @status_3.active)

    TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    han_active_status = TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    leia_active_status = TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)

    conn = get(conn, search_path(conn, :list_status, @status_2.description, limit: 2, offset: 1))

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

  test "list subset of status results when queried by username or email with given limit/offset", %{conn: conn} do
    user_luke = TestCommon.create_user(Repo, @default_user.username, @default_user.password, @default_user.email)
    user_han = TestCommon.create_user(Repo, "han_solo", "smuggler", "han@solo.com")
    user_leia = TestCommon.create_user(Repo, "leia_organa", "princess", "pricess@leia.com")
    user_vader = TestCommon.create_user(Repo, "darth_vader", "darksith", "darth@vader.com")
    user_anakin = TestCommon.create_user(Repo, "anakin_skywalker", "chosenone", "anakin@skywalker.com")

    # Shmi remarried and surname changed to Lars, but she never updated her email address!
    # Shmi should still show up in the search results

    user_shmi = TestCommon.create_user(Repo, "shmi_lars", "slavemother", "shmi@skywalker.com")

    TestCommon.create_status(Repo, user_han.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_leia.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_vader.id, @status_2.description, @status_2.active)

    luke_active_status = TestCommon.create_status(Repo, user_luke.id, @status_2.description, @status_2.active)
    anakin_active_status = TestCommon.create_status(Repo, user_anakin.id, @status_2.description, @status_2.active)
    TestCommon.create_status(Repo, user_shmi.id, @status_2.description, @status_2.active)

    conn = get(conn, search_path(conn, :list_user, "skywalker", limit: 2, offset: 1))

    expected = [
                 %{
                   "since" => TestCommon.date_to_json(anakin_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_anakin.username
                 },
                 %{
                   "since" => TestCommon.date_to_json(luke_active_status.updated_at),
                   "status" => @status_2.description,
                   "username" => user_luke.username
                 }
               ]

    assert json_response(conn, 200)["data"] == expected
  end

end
