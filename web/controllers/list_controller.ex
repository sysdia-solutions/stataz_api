defmodule StatazApi.ListController do
  use StatazApi.Web, :controller

  alias StatazApi.ListController.ActionShow

  def new_users(conn, params) do
    ActionShow.execute(conn, params, :new, :user)
  end

  def new_statuses(conn, params) do
    ActionShow.execute(conn, params, :new, :status)
  end

  def popular_statuses(conn, params) do
    ActionShow.execute(conn, params, :popular, :status)
  end
end
