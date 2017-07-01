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

    scope "/auth", Amazon do
        pipe_through :api

        post "/login", LoginController, :create

        get "/logout", LoginController, :delete

        pipe_through :browser

        get "/:provider", LoginController, :index

        get "/:provider/callback", LoginController, :callback
    end

    scope "/api", Amazon do
        pipe_through :api

        get "/shop/:page", HomeController, :show

        get "/product/:id", ProductController, :show

        scope "/user" do
            get "/cart", CartController, :show

            post "/cart/add", CartController, :create

            delete "/cart/remove/:id", CartController, :remove

            get "/checkout", CheckoutController, :show

            post "/checkout/confirm", CheckoutController, :create

            get "/orders", OrderController, :show

            get "/settings", ProfileController, :show

            post "/update", ProfileController, :update
        end
    end

    scope "/", Amazon do
        pipe_through :browser # Use the default browser stack

        get "/*path", PageController, :index
    end
end
