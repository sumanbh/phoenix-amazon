defmodule Amazon.Router do
  use Amazon.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/api", Amazon do
    pipe_through :api

    get "/shop/:page", HomeController, :show

    get "/product/:id", ProductController, :show

    get "/user/cart", CartController, :show

    post "/user/cart/add", CartController, :add

  end

  scope "/login", Amazon do
    pipe_through :api

    post "/", LoginController, :create

  end

  scope "/", Amazon do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end
end
