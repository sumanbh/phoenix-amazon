defmodule Amazon.Home do
    use Amazon.Web, :model

    alias __MODULE__
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
        options = Poison.Parser.parse!(obj["obj"])
        keys = Map.keys(options)
        truthy_keys = Enum.filter(keys, fn(keys) -> options[keys] == true end)
        brand_names = %{
            "Asus" => "Asus",
            "Acer" => "Acer",
            "Apple" => "Apple",
            "HP" => "HP",
            "Microsoft" => "Microsoft",
            "Lenovo" => "Lenovo",
            "Dell" => "Dell",
            "Samsung" => "Samsung",
        }
        os_names = %{
            "Mac" => "Mac OS X",
            "Win10" => "Windows 10",
            "Chrome" => "Chrome OS",
            "Win8" => "Windows 8.1",
            "Win7" => "Windows 7 Home",
        }
        processor_names = %{
            "i7" => "Intel Core i7",
            "i5" => "Intel Core i5",
            "i3" => "Intel Core i3",
            "Core2" => "Intel Core 2",
            "Athlon" => "AMD",
        }
        storage_names = %{
            "SSD" => "SSD",
            "HardDrive" => "Hard Disk",
        }
        price_names = %{
            "isUnder500" => %{ "min" => 0, "max" => 500 },
            "is500to600" => %{ "min" => 500, "max" => 600 },
            "is600to700" => %{ "min" => 600, "max" => 700 },
            "is700to800" => %{ "min" => 700, "max" => 800 },
            "is800to900" => %{ "min" => 800, "max" => 900 },
            "is900to1000" => %{ "min" => 900, "max" => 1000 },
            "isAbove1000" => %{ "min" => 1000, "max" => 20000 },
        }
        ram_names = %{
            "is64andAbove" => "64", "is32" => "32", "is16" => "16", "is8" => "8", "is4" => "4", "is2" => "2", "is12" => "12",
        }

        price = truthy_keys
            |> Enum.filter(&(Map.has_key?(price_names, &1)))
            |> Enum.map(&(Map.get(price_names, &1)))
            |> Enum.at(0)
                
        min = (Map.has_key?(obj, "min")) && Numlib.string_to_int(obj["min"]) || price["min"] || 0
        max = (Map.has_key?(obj, "max")) && Numlib.string_to_int(obj["max"]) || price["max"] || 20000

        os = truthy_keys
            |> Enum.filter(&(Map.has_key?(os_names, &1)))
            |> Enum.map(&(Map.get(os_names, &1)))
            |> Enum.join(",")
        
        brand = truthy_keys
            |> Enum.filter(&(Map.has_key?(brand_names, &1)))
            |> Enum.map(&(Map.get(brand_names, &1)))
            |> Enum.join(",")
        
        processor = truthy_keys
            |> Enum.filter(&(Map.has_key?(processor_names, &1)))
            |> Enum.map(&(Map.get(processor_names, &1)))
            |> Enum.join(",")
        
        storage = truthy_keys
            |> Enum.filter(&(Map.has_key?(storage_names, &1)))
            |> Enum.map(&(Map.get(storage_names, &1)))
            |> Enum.join(",")
        
        ram = truthy_keys
            |> Enum.filter(&(Map.has_key?(ram_names, &1)))
            |> Enum.map(&(Map.get(ram_names, &1)))
            |> Enum.join(",")
        
        {brand, os, ram, processor, storage, min, max}
    end
end