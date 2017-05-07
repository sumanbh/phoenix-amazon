defmodule Amazon.Checkout do
    use Amazon.Web, :model

    alias __MODULE__

    def get_user(user) do
        query = """
                SELECT address, city, fullname, state, zip FROM customers WHERE id = $1;
                """
        %{query: query, params: [user]}
    end

    def get_cart(user) do
        query = """
                SELECT * FROM cart WHERE customer_id = $1;
                """
        %{query: query, params: [user]}
    end

    def insert_orderline(user) do
        query = """
                INSERT INTO orderline(customer_id, order_total) VALUES($1, (SELECT SUM(price * product_quantity) FROM cartview WHERE customer_id = $1)) RETURNING orderline.id;
                """
        %{query: query, params: [user]}
    end

    def delete_cart(user) do
        query = """
                DELETE FROM cart WHERE id IN (SELECT id FROM cart WHERE customer_id = $1);
                """
        %{query: query, params: [user]}
    end
end
