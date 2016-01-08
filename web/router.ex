defmodule StatazApi.Router do
  use StatazApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug StatazApi.Auth, repo: StatazApi.Repo
  end

  scope "/users", StatazApi do
    pipe_through :api
    post "/", UserController, :create

    pipe_through :auth
    get "/:username", UserController, :show
    delete "/:username", UserController, :delete
    put "/:username", UserController, :update
  end

  scope "/auth", StatazApi do
    pipe_through :api
    post "/", AuthController, :create

    pipe_through :auth
    get "/:username", AuthController, :show
    delete "/:username", AuthController, :delete
  end
end
