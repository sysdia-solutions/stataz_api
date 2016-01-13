defmodule StatazApi.FollowController do
  use StatazApi.Web, :controller

  alias StatazApi.FollowController.ActionCreate
  alias StatazApi.FollowController.ActionDelete
  alias StatazApi.FollowController.ActionShow

  def create(conn, params) do
    ActionCreate.execute(conn, params)
  end

  def delete(conn, params) do
    ActionDelete.execute(conn, params)
  end

  def show(conn, params) do
    ActionShow.execute(conn, params)
  end

  def public_show(conn, params) do
    ActionShow.execute(conn, params)
  end
end
