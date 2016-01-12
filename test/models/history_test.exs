defmodule StatazApi.HistoryTest do
  use StatazApi.ModelCase

  alias StatazApi.History

  @valid_attrs %{description: "flying"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = History.changeset(%History{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = History.changeset(%History{}, @invalid_attrs)
    refute changeset.valid?
  end
end
