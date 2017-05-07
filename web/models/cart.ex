defmodule Amazon.Cart do
    use Amazon.Web, :model

    alias __MODULE__

    def get_cart(user) do
        query = """
                SELECT brand_name, img, laptops_id, name, price, product_quantity, unique_id from cartview WHERE customer_id = $1 ORDER BY date_added DESC;
                """
        %{query: query, params: [user]}
    end

    def get_total_price(user) do
        query = """
                SELECT SUM(price * product_quantity) AS total FROM cartview WHERE customer_id = $1;
                """
        %{query: query, params: [user]}
    end

    def check_cart(product, user) do
        query = """
                SELECT * FROM cart WHERE product_id = $1 AND customer_id = $2;
                """
        %{query: query, params: [product, user]}
    end

    def insert_new(product, quantity, user) do
        query = """
                INSERT INTO cart(product_id, product_quantity, customer_id) VALUES ($1, $2, $3);
                """
        %{query: query, params: [product, quantity, user]}
    end

    def remove_product(user, product) do
        query = """
                DELETE FROM cart WHERE customer_id = $1 AND id = $2;
                """
        %{query: query, params: [user, product]}
    end

    def update_old(new_total, user, product) do
        query = """
                UPDATE cart SET product_quantity = ($1) WHERE customer_id = ($2) and product_id = ($3);
                """
        %{query: query, params: [new_total, user, product]}
    end
end
