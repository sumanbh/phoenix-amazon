defmodule Amazon.LoginController do
    use Amazon.Web, :controller

    alias Amazon.{Login, LoginView, CartTotal, Postgres}
    alias Guardian.{Plug}

    plug :scrub_params, "email" when action in [:create]
    plug :scrub_params, "password" when action in [:create]

    def create(conn, %{"email" => email, "password" => password}) do
        case Login.authenticate(email, password) do
        {:ok, user} ->
            [cart | _] = CartTotal.get_cart(user.id)
                        |> Postgres.raw_query()
            {:ok, jwt, _} = user |> Guardian.encode_and_sign(:token, name: user.given_name)
            conn
            |> put_status(:created)
            |> render("show.json", jwt: jwt, success: true, cart: cart["total"] || 0)

        :error ->
            conn
            # |> put_status(:unprocessable_entity)
            |> render("error.json")
        end
    end

    def delete(conn, _) do
        {:ok, claims} = Plug.claims(conn)

        conn
        |> Plug.current_token
        |> Guardian.revoke!(claims)

        conn
        |> render("delete.json")
    end

    def unauthenticated(conn, _params) do
        conn
        |> put_status(:forbidden)
        |> render(LoginView, "forbidden.json", error: "Not Authenticated")
    end
end
