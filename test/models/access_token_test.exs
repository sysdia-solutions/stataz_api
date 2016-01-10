defmodule StatazApi.AccessTokenTest do
  use StatazApi.ModelCase

  alias StatazApi.AccessToken

  @valid_attrs %{token: "tydirium", expires: StatazApi.Util.Time.ecto_now()}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AccessToken.changeset(%AccessToken{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AccessToken.changeset(%AccessToken{}, @invalid_attrs)
    refute changeset.valid?
  end
end
