defmodule StatazApi.Router do
  use StatazApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug StatazApi.Auth, repo: StatazApi.Repo
  end

  scope "/user", StatazApi do
    pipe_through :api
    post "/", UserController, :create

    pipe_through :auth
    get "/", UserController, :show
    delete "/", UserController, :delete
    put "/", UserController, :update
  end

  scope "/auth", StatazApi do
    pipe_through :api
    post "/", AuthController, :create

    pipe_through :auth
    get "/", AuthController, :show
    delete "/", AuthController, :delete
  end

  scope "/status", StatazApi do
    pipe_through :api

    get "/:username", StatusController, :profile

    pipe_through :auth

    get "/", StatusController, :list
    post "/", StatusController, :create
    delete "/:id", StatusController, :delete
    put "/:id", StatusController, :update
  end

  scope "/follow", StatazApi do
    pipe_through :api

    get "/:username", FollowController, :public_show

    pipe_through :auth

    get "/", FollowController, :show
    post "/:username", FollowController, :create
    delete "/:username", FollowController, :delete
  end

  scope "/search", StatazApi do
    pipe_through :api

    get "/user/:query", SearchController, :list_user
    get "/status/:query", SearchController, :list_status
  end

  scope "/list", StatazApi do
    pipe_through :api

    get "/new/users", ListController, :new_users
    get "/new/statuses", ListController, :new_statuses
    get "/popular/statuses", ListController, :popular_statuses
  end
end
