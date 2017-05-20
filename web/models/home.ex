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
                WHERE ($1 = '' OR LOWER(brand.name) = ANY(STRING_TO_ARRAY(LOWER($1), ',')))
                AND ($2 = '' OR LOWER(os.name) = ANY(STRING_TO_ARRAY(LOWER($2), ',')))
                AND ($3 = '' OR laptops.ram = ANY(STRING_TO_ARRAY($3, ',')))
                AND ($4 = '' OR LOWER(processor.name) = ANY(STRING_TO_ARRAY(LOWER($4), ',')))
                AND ($5 = '' OR LOWER(storage_type.name) = ANY(STRING_TO_ARRAY(LOWER($5), ',')))
                AND laptops.price >= ($6)
                AND laptops.price < ($7);
                """
        %{query: query, params: [brand, os, ram, processor, storage, min, max]}
    end

    def filter_truthy(obj) do
        options = Parser.parse!(obj["obj"])

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

        min = (Map.has_key?(obj, "min")) && Numlib.string_to_int(obj["min"]) || 0
        max = (Map.has_key?(obj, "max")) && Numlib.string_to_int(obj["max"]) || 20_000

        {brand, os, ram, processor, storage, min, max}
    end
end
