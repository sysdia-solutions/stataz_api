defmodule StatazApi.StatusController do
  use StatazApi.Web, :controller

  alias StatazApi.StatusController.ActionCreate
  alias StatazApi.StatusController.ActionDelete
  alias StatazApi.StatusController.ActionUpdate
  alias StatazApi.StatusController.ActionList
  alias StatazApi.StatusController.ActionProfile

  def create(conn, params) do
    ActionCreate.execute(conn, params)
  end

  def delete(conn, params) do
    ActionDelete.execute(conn, params)
  end

  def update(conn, params) do
    ActionUpdate.execute(conn, params)
  end

  def list(conn, _params) do
    ActionList.execute(conn)
  end

  def profile(conn, params) do
    ActionProfile.execute(conn, params)
  end
end
