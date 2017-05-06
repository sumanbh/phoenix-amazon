defmodule Amazon.CartTotal do
    use Amazon.Web, :model

    alias __MODULE__

    def get_cart(id) do
        query = """
                SELECT SUM(product_quantity) as total FROM cartview WHERE customer_id = $1;
                """
        %{query: query, params: [id]}
    end
end
