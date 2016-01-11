defmodule StatazApi.UserController do
  use StatazApi.Web, :controller

  alias StatazApi.UserController.ActionShow
  alias StatazApi.UserController.ActionCreate
  alias StatazApi.UserController.ActionUpdate
  alias StatazApi.UserController.ActionDelete

  def create(conn, user_params) do
    ActionCreate.execute(conn, user_params)
  end

  def show(conn, _params) do
    ActionShow.execute(conn)
  end

  def update(conn, params) do
    ActionUpdate.execute(conn, params)
  end

  def delete(conn, _params) do
    ActionDelete.execute(conn)
  end
end
