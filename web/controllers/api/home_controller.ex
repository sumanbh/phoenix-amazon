defmodule Amazon.HomeController do
    use Amazon.Web, :controller
    
    alias Amazon.{Home, Postgres, Numlib}

    def show(conn, params) do
        page = Numlib.string_to_int(params["page"])
        limit = 24
        offset = (page - 1) * 24

        listings = Home.get_listings(params)
                |> Postgres.raw_query()
        total = length(listings)
        data = Enum.slice(listings, offset, limit)

        render(conn, "index.json", total: total, data: data )
    end
end