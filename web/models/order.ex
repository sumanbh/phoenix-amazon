defmodule Amazon.Order do
    use Amazon.Web, :model

    schema "orders" do
        field :orderline_id, :integer
        field :product_id, :integer
        field :quantity, :integer
        field :fullname, :string
        field :address, :string
        field :city, :string
        field :zip, :string
        field :state, :string
    end

    @required_fields ~w(given_:orderline_id product_id quantity fullname address city zip state)

    def get_orders(user) do
        query = """
                SELECT laptops.id AS laptop_id, laptops.name AS laptop_name, laptops.img, laptops.price, orderline.id, orderline.order_total,orderline.date_added::text, orders.quantity, orders.fullname, orders.address, orders.city, orders.state, orders.zip
                FROM orders
                JOIN laptops on laptops.id = orders.product_id
                JOIN orderline on orderline.id = orders.orderline_id
                WHERE orderline.customer_id = $1
                ORDER BY orderline.date_added DESC;
                """
        %{query: query, params: [user]}
    end

    @doc """
    Creates a changeset based on the `model` and `params`.

    If no params are provided, an invalid changeset is returned
    with no validation performed.
    """
    # def changeset(model, params \\ %{}) do
    #     model
    #     |> cast(params, @required_fields, @optional_fields)
    # end
end
