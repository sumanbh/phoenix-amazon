defmodule Amazon.Home do
    use Amazon.Web, :model

    alias __MODULE__
    alias Poison.{Parser}
    alias Amazon.{Numlib}

    def get_listings(obj) do
        {brand, os, ram, processor, storage, min, max} = filter_truthy(obj)
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
        %{query: query, params: [brand, os, ram, processor, storage, min, max]}
    end

    def filter_truthy(obj) do
        options = Parser.parse!(obj["obj"])
        price_options = %{
           "isUnder500" => %{"min"=> 0,"max"=> 500},
           "is500to600" => %{"min"=> 500,"max"=> 600},
           "is600to700" => %{"min"=> 600,"max"=> 700},
           "is700to800" => %{"min"=> 700,"max"=> 800},
           "is800to900" => %{"min"=> 800,"max"=> 900},
           "is900to1000" => %{"min"=> 900,"max"=> 1000},
           "isAbove1000" => %{"min"=> 1000,"max"=> 20_000},
        }

        price = options["price"]
            |> Enum.filter(&(Map.has_key?(price_options, &1)))
            |> Enum.map(&(Map.get(price_options, &1)))
            |> Enum.at(0)

        os = options["os"]
            |> Map.keys()
            |> Enum.filter(fn(x) -> options["os"][x] == true end)
            |> Enum.join(",")

        brand = options["brand"]
            |> Map.keys()
            |> Enum.filter(fn(x) -> options["brand"][x] == true end)
            |> Enum.join(",")

        processor = options["processor"]
            |> Map.keys()
            |> Enum.filter(fn(x) -> options["processor"][x] == true end)
            |> Enum.join(",")

        storage = options["storage"]
            |> Map.keys()
            |> Enum.filter(fn(x) -> options["storage"][x] == true end)
            |> Enum.join(",")

        ram = options["ram"]
            |> Map.keys()
            |> Enum.filter(fn(x) -> options["ram"][x] == true end)
            |> Enum.join(",")

        min = (Map.has_key?(obj, "min")) && Numlib.string_to_int(obj["min"]) || price["min"] || 0
        max = (Map.has_key?(obj, "max")) && Numlib.string_to_int(obj["max"]) || price["max"] || 20_000

        {brand, os, ram, processor, storage, min, max}
    end
end
