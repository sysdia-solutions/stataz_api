defmodule StatazApi.SearchController do
  use StatazApi.Web, :controller

  alias StatazApi.SearchController.ActionShow

  def list_user(conn, params) do
    ActionShow.execute(conn, params, :user)
  end

  def list_status(conn, params) do
    ActionShow.execute(conn, params, :status)
  end
end
