defmodule StatazApi.AuthController do
  use StatazApi.Web, :controller

  alias StatazApi.AuthController.ActionCreate
  alias StatazApi.AuthController.ActionDelete
  alias StatazApi.AuthController.ActionShow

  def create(conn, login_params) do
    ActionCreate.execute(conn, login_params)
  end

  def delete(conn, _params) do
    ActionDelete.execute(conn)
  end

  def show(conn, _params) do
    ActionShow.execute(conn)
  end
end
