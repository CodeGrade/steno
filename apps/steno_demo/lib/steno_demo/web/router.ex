defmodule StenoDemo.Web.Router do
  use StenoDemo.Web, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    #plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StenoDemo.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/uploads", UploadController
    resources "/jobs", JobController
    post "/jobs/:id/run", JobController, :run
  end

  # Other scopes may use custom stacks.
  # scope "/api", StenoDemo.Web do
  #   pipe_through :api
  # end
end
