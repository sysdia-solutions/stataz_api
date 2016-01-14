defmodule StatazApi.AuthController do
  use StatazApi.Web, :controller

  alias StatazApi.AuthController.ActionCreate
  alias StatazApi.AuthController.ActionDelete

  def create(conn, login_params) do
    ActionCreate.execute(conn, login_params)
  end

  def delete(conn, params) do
    ActionDelete.execute(conn, params)
  end
end
