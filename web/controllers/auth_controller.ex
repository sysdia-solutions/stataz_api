defmodule StatazApi.AuthController do
  use StatazApi.Web, :controller

  alias StatazApi.AuthController.ActionCreate
  alias StatazApi.AuthController.ActionDelete
  alias StatazApi.AuthController.ActionShow

  def create(conn, login_params) do
    ActionCreate.execute(conn, login_params)
  end

  def delete(conn, params) do
    ActionDelete.execute(conn, params)
  end

  def show(conn, params) do
    ActionShow.execute(conn, params)
  end
end
