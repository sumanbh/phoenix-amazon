defmodule Amazon.CartController do
    use Amazon.Web, :controller
    plug Guardian.Plug.EnsureAuthenticated, handler: Amazon.LoginController

    alias Amazon.{Cart, Postgres, CartTotal}
    alias Guardian.{Plug}

    def show(conn, _params) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        results = Cart.get_cart(user_id)
                |> Postgres.raw_query()
        if length(results) > 0 do
            [price | _] = Cart.get_total_price(user_id)
                |> Postgres.raw_query()
            [cart | _] = CartTotal.get_cart(user_id)
                |> Postgres.raw_query()
            conn
            |> put_status(:created)
            |> json(%{sum: price, data: results, cart: cart["total"] || 0})
        else
            conn
            |> put_status(:created)
            |> json(results)
        end
    end

    def add(conn, %{"productId" => product, "productQuantity" => quantity}) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        [cart | _] = CartTotal.get_cart(user_id)
                |> Postgres.raw_query()
        exists = Cart.check_cart(product, user_id)
                |> Postgres.raw_query()
        if length(exists) == 0  do
            Cart.insert_new(product, quantity, user_id)
                |> Postgres.raw_query()
            cart_total = (cart["total"] || 0) + quantity
            conn
            |> put_status(:created)
            |> json(%{cart: cart_total, success: true})
        else
            [found | _] = exists
            new_total = found["product_quantity"] + quantity
            Cart.update_old(new_total, user_id, product)
                |> Postgres.raw_query()
            cart_total = (cart["total"] || 0) + quantity
            conn
            |> put_status(:created)
            |> json(%{cart: cart_total, success: true})
        end
    end
end
