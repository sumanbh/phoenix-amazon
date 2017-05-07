defmodule Amazon.OrderController do
    use Amazon.Web, :controller
    plug Guardian.Plug.EnsureAuthenticated, handler: Amazon.LoginController

    alias Amazon.{Order, Postgres}
    alias Guardian.{Plug}

    def show(conn, _params) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        result = Order.get_orders(user_id)
                |> Postgres.raw_query()
        conn
        |> put_status(:ok)
        |> json(result)
    end
end
