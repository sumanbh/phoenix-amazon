defmodule Amazon.ProductController do
    use Amazon.Web, :controller
    
    alias Amazon.{Product, Postgres, Numlib}

    def show(conn, %{"id" => id}) do
        product_id = Numlib.string_to_int(id)

        product = Product.get_product(product_id)
                |> Postgres.raw_query()

        if length(product) == 0 do
            conn 
            |> put_status(404) 
            |> json(%{error: "Product not found"})
        else
            [head | _tail] = product
            price = round(Decimal.to_float(head["price"]))

            similar = Product.get_similar(price, product_id)
                |> Postgres.raw_query()
                |> Enum.take(3)

            render(conn, "index.json", product: product, similar: similar )
        end
        
    end
end