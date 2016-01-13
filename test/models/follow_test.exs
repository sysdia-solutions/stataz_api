defmodule StatazApi.FollowTest do
  use StatazApi.ModelCase

  alias StatazApi.Follow

  @valid_attrs %{follower_id: "1", following_id: "2"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Follow.changeset(%Follow{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Follow.changeset(%Follow{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid attributes follower_id same as following_id" do
    changeset = Follow.changeset(%Follow{}, %{follower_id: "1", following_id: "1"})
    refute changeset.valid?
  end
end
