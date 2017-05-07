defmodule Amazon.ProfileController do
    use Amazon.Web, :controller
    plug Guardian.Plug.EnsureAuthenticated, handler: Amazon.LoginController

    alias Amazon.{Profile, Postgres}
    alias Guardian.{Plug}

    def show(conn, _params) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        result = Profile.get_user(user_id)
                |> Postgres.raw_query()
        conn
        |> put_status(:ok)
        |> json(result)
    end

    def update(conn, %{"given_name" => given_name, "fullname" => fullname, "address" => address, "city" => city, "state" => state, "zip" => zip}) do
        current_user = Plug.current_resource(conn)
        user_id = current_user.id

        result = Profile.update_user(given_name, fullname, address, city, state, zip, user_id)
                |> Postgres.raw_query()
        conn
        |> put_status(:ok)
        |> json(result)
    end
end
