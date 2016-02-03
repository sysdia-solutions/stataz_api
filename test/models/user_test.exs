defmodule StatazApi.UserTest do
  use StatazApi.ModelCase

  alias StatazApi.User

  @valid_attrs %{email: "luke@skywalker.com", password_hash: "rebellion", username: "luke_skywalker"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid username attribute" do
    attrs = %{username: "R2"}
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?

    attrs = %{username: "Grand_Moff_Wilhuff_Tarkin"}
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?

    attrs = %{username: "luke.skywalker"}
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
  end

  test "changeset with invalid email attribute" do
    attrs = %{username: "luke_skywalker", email: "luke"}
    changeset = User.changeset(%User{}, attrs)
    refute changeset.valid?
  end

  test "create_changeset with invalid password attribute" do
    attrs = %{username: "luke_skywalker", password: "rebel"}
    changeset = User.create_changeset(%User{}, attrs)
    refute changeset.valid?
  end

  test "update_changeset with invalid password attribute" do
    attrs = %{username: "luke_skywalker", password: "rebel"}
    changeset = User.update_changeset(%User{}, attrs)
    refute changeset.valid?
  end
end
