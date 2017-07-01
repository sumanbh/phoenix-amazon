defmodule Amazon.LoginController do
    use Amazon.Web, :controller

    alias Amazon.{Login, LoginView, CartTotal, Postgres, Google, Facebook}
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

    def index(conn, %{"provider" => provider}) do
        redirect conn, external: authorize_url!(provider)
    end

    def delete(conn, _) do
        conn
        |> render("delete.json")
    end

    def unauthenticated(conn, _params) do
        conn
        |> put_status(:forbidden)
        |> render(LoginView, "forbidden.json", error: "Not Authenticated")
    end


    def callback(conn, %{"provider" => provider, "code" => code}) do
        # Exchange an auth code for an access token
        client = get_token!(provider, code)

        # Request the user's data with the access token
        response = get_user(provider, client)
        case response do
            {:error, error} ->
                conn
                |> put_flash(:error, error)
                |> redirect(to: "/")

            {:user, user} ->
                result = check_database!(provider, user)
                        |> Postgres.raw_query()
                if length(result) == 0 do
                    res = insert_user!(provider, user)
                        |> Postgres.raw_query()
                    [head | _tail] = res
                    new_user = for {key, val} <- head, into: %{}, do: {String.to_atom(key), val}

                    {:ok, jwt, _} = new_user |> Guardian.encode_and_sign(:token, name: new_user.given_name)

                    conn
                    |> redirect(to: "/validate?cart=0&token=#{jwt}")
                else
                    [head | _tail] = result
                    user_found = for {key, val} <- head, into: %{}, do: {String.to_atom(key), val}

                    [cart | _] = CartTotal.get_cart(user_found.id)
                                |> Postgres.raw_query()
                    {:ok, jwt, _} = user_found |> Guardian.encode_and_sign(:token, name: user_found.given_name)

                    conn
                    |> redirect(to: "/validate?cart=#{cart["total"]}&token=#{jwt}")
                end
        end
    end

    defp get_user(provider, client) do
        case client.token.other_params do
            %{"error" => error, "error_description" => description} ->
                {:error, error <> " " <> description}
            _ ->
                # Request the user's data with the access token
                user = user_request!(provider, client)
                case user do
                    {:error, message} ->
                        {:error, message}
                    {:user, user} ->
                        {:user, user}
                end
        end
    end

    defp authorize_url!("google"),   do: Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
    defp authorize_url!("facebook"), do: Facebook.authorize_url!(scope: "public_profile,email")
    defp authorize_url!(_), do: raise "No matching provider available"

    defp get_token!("google", code),   do: Google.get_token!(code: code)
    defp get_token!("facebook", code), do: Facebook.get_token!(code: code)
    defp get_token!(_, _), do: raise "No matching provider available"

    def check_database!("google", user), do: Google.check_database(user.id, user.email)
    def check_database!("facebook", user), do: Facebook.check_database(user.id, user.email)
    def check_database!(_, _), do: raise "No matching provider available"

    def insert_user!("google", user), do: Google.insert_user(user.id, user.email, user.name, user.given_name)
    def insert_user!("facebook", user), do: Facebook.insert_user(user.id, user.email, user.name, user.given_name)
    def insert_user!(_, _), do: raise "No matching provider available"

    defp user_request!("google", client) do
        response = OAuth2.Client.get!(client, "https://www.googleapis.com/plus/v1/people/me/openIdConnect")
        case response do
            %{body: %{"error" => error}} ->
                messages = Enum.map(error["errors"], fn(err) -> err["message"] end)
                {:error, Enum.join(messages, ",\n")}
            %{body: user} ->
                {:user, %{name: user["name"], id: user["sub"], email: user["email"], given_name: user["given_name"]}}
        end
    end
    defp user_request!("facebook", client) do
        response = OAuth2.Client.get!(client, "/me?fields=id,name,email,first_name")
        case response do
            %{body: user} ->
                {:user, %{name: user["name"], id: user["id"], email: user["email"] || nil, given_name: user["first_name"]}}
            _ -> {:error, response}
        end
    end

end
