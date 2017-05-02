defmodule Amazon.ShopController do
    use Amazon.Web, :controller

    alias Amazon.{Shop, Listings}

    def show(conn, params) do
        page = string_to_int(params["page"])
        limit = 24
        offset = (page - 1) * 24
        query = """
                SELECT laptops.id, laptops.img, laptops.price, laptops.rating, laptops.name FROM laptops
                join brand ON laptops.brand_id = brand.id
                join os ON laptops.os_id = os.id
                join processor ON laptops.processor_id = processor.id
                join storage_type ON laptops.storage_type_id = storage_type.id
                WHERE ($1 = '' OR brand.name = ANY(STRING_TO_ARRAY($1, ',')))
                AND ($2 = '' OR os.name = ANY(STRING_TO_ARRAY($2, ',')))
                AND ($3 = '' OR laptops.ram = ANY(STRING_TO_ARRAY($3, ',')))
                AND ($4 = '' OR processor.name = ANY(STRING_TO_ARRAY($4, ',')))
                AND ($5 = '' OR storage_type.name = ANY(STRING_TO_ARRAY($5, ',')))
                AND laptops.price >= ($6) 
                AND laptops.price < ($7);
                """
        result = Ecto.Adapters.SQL.query!(Amazon.Repo, query, ["","","","","",0,20000])

        res = Enum.map result.rows, fn(row) ->
            Enum.reduce(Enum.zip(result.columns, row), %{}, fn({key, value}, map) ->
            Map.put(map, key, value)
            end)
        end
        
        json(conn, %{total: length(res), data: Enum.slice(res, offset, limit)})
    end

    defp string_to_int(val \\ 1) do
       String.to_integer(val, 10) 
    end
end