defmodule Amazon.CheckoutController do
    use Amazon.Web, :controller
    plug Guardian.Plug.EnsureAuthenticated, handler: Amazon.LoginController

    alias Amazon.{Cart, Postgres, Checkout, Order, Repo}
    alias Guardian.{Plug}

    def show(conn, _params) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        results = Cart.get_cart(user_id)
                |> Postgres.raw_query()
        if length(results) > 0 do
            [price | _] = Cart.get_total_price(user_id)
                |> Postgres.raw_query()
            user = Checkout.get_user(user_id)
                |> Postgres.raw_query()
            conn
            |> put_status(:ok)
            |> json(%{sum: price, data: results, userInfo: user})
        else
            conn
            |> put_status(:ok)
            |> json(results)
        end
    end

    def create(conn, %{"address" => address, "city" => city, "fullname" => fullname, "zip" => zip, "state" => state}) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        results = Checkout.get_cart(user_id)
            |> Postgres.raw_query()
        if length(results) > 0 do
            [orderline | _] = Checkout.insert_orderline(user_id)
                |> Postgres.raw_query()
            order_list = Enum.map(results, fn(x) ->
                [orderline_id: orderline["id"], product_id: x["product_id"], quantity: x["product_quantity"], fullname: fullname, address: address, city: city, state: state, zip: to_string(zip)] end)
            Repo.insert_all(Order, order_list)
            Checkout.delete_cart(user_id) |> Postgres.raw_query()
            conn
            |> put_status(:created)
            |> json(%{cart: 0, success: true})
        else
            conn
            |> put_status(:no_content)
            |> json(results)
        end

    end
end
