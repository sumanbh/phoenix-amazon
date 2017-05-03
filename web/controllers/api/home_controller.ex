defmodule Amazon.HomeController do
    use Amazon.Web, :controller

     alias Amazon.{Home, Shared}

    def show(conn, params) do
        page = string_to_int(params["page"])
        limit = 24
        offset = (page - 1) * 24

        listings = Home.get_listings(params) |> Shared.raw_query()
        total = length(listings)
        data = Enum.slice(listings, offset, limit)

        render(conn, "index.json", total: total, data: data )
    end

    defp string_to_int(val \\ 1) do
       String.to_integer(val, 10) 
    end
end