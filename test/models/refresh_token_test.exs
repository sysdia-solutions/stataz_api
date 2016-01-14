defmodule StatazApi.RefreshTokenTest do
  use StatazApi.ModelCase

  alias StatazApi.RefreshToken

  @valid_attrs %{token: "tydirium", client_id: "deathstar"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RefreshToken.changeset(%RefreshToken{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RefreshToken.changeset(%RefreshToken{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid client_id attribute" do
    attrs = %{@valid_attrs | client_id: "yavin4"}
    changeset = RefreshToken.changeset(%RefreshToken{}, attrs)
    refute changeset.valid?
  end
end
