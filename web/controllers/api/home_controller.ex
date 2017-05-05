defmodule Amazon.HomeController do
    use Amazon.Web, :controller
    
    alias Amazon.{Home, Postgres, Numlib}

    def show(conn, params) do
        page = Numlib.string_to_int(params["page"])
        limit = 24
        offset = (page - 1) * 24

        listings = Home.get_listings(params)
                |> Postgres.raw_query()
                |> (fn(x) -> %{"total" => length(x), "data" => Enum.slice(x, offset, limit)} end).()

        render(conn, "index.json", total: listings["total"], data: listings["data"])
    end
end