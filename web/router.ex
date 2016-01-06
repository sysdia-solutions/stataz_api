defmodule StatazApi.Router do
  use StatazApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/users", StatazApi do
    pipe_through :api

    post "/", UserController, :create

    get "/:username", UserController, :show
    delete "/:username", UserController, :delete
    put "/:username", UserController, :update
  end
end
