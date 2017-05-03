defmodule Amazon.Product do
    use Amazon.Web, :model

    alias __MODULE__

    def get_product(id) do
        query = """
                SELECT laptops.id, laptops.name AS laptop_name, laptops.img, laptops.ram, laptops.storage, laptops.img_big, laptops.price, laptops.rating, laptops.description, os.name AS os_name, brand.name AS brand_name, storage_type.name AS storage_name from laptops
                JOIN brand ON laptops.brand_id = brand.id
                JOIN os ON laptops.os_id = os.id
                JOIN storage_type ON laptops.storage_type_id = storage_type.id
                WHERE laptops.id = $1;
                """
        %{query: query, params: [id]}
    end

    def get_similar(price, id) do
        query = """
                SELECT laptops.id, laptops.name AS laptop_name, laptops.rating, laptops.img, laptops.price, laptops.ram, laptops.storage, os.name AS os_name, brand.name AS brand_name, storage_type.name AS storage_name from laptops
                JOIN brand ON laptops.brand_id = brand.id
                JOIN os ON laptops.os_id = os.id
                JOIN storage_type ON laptops.storage_type_id = storage_type.id
                WHERE laptops.price <= ($1 + 150) AND laptops.price >= ($1 - 250)
                AND laptops.id != $2;
                """
        %{query: query, params: [price, id]}
    end

end