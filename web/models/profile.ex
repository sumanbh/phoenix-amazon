defmodule Amazon.Profile do
    use Amazon.Web, :model

    alias __MODULE__

    def get_user(user) do
        query = """
                SELECT customers.given_name, customers.fullname, customers.address, customers.city, customers.state, customers.zip, customers.date_added::text from customers
                WHERE customers.id = $1
                LIMIT 1;
                """
        %{query: query, params: [user]}
    end

    def update_user(given_name, fullname, address, city, state, zip, user) do
        query = """
                UPDATE customers SET given_name = ($1), fullname = ($2), address = ($3), city = ($4), state = ($5), zip = ($6) WHERE id = ($7);
                """
        %{query: query, params: [given_name, fullname, address, city, state, zip, user]}
    end
end
