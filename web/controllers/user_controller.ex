defmodule StatazApi.UserController do
  use StatazApi.Web, :controller

  alias StatazApi.UserController.ActionShow
  alias StatazApi.UserController.ActionCreate
  alias StatazApi.UserController.ActionUpdate
  alias StatazApi.UserController.ActionDelete

  def create(conn, user_params) do
    ActionCreate.execute(conn, user_params)
  end

  def show(conn, %{"username" => username}) do
    ActionShow.execute(conn, username)
  end

  def update(conn, %{"username" => username}) do
    ActionUpdate.execute(conn, username)
  end

  def delete(conn, %{"username" => username}) do
    ActionDelete.execute(conn, username)
  end
end
