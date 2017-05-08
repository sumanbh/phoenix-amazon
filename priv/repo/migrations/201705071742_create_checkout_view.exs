defmodule Amazon.Repo.Migrations.CreateCheckoutView do
    use Ecto.Migration

    def up do
        execute """
                CREATE view checkoutview
                AS
                    SELECT cart.customer_id,
                            customers.fullname,
                            customers.address,
                            customers.state,
                            customers.zip,
                            customers.phone,
                            cart.product_quantity,
                            laptops.id AS laptops_id,
                            laptops.price,
                            laptops.img,
                            brand.name AS brand_name,
                            laptops.name,
                            cart.date_added
                FROM   cart
                        JOIN customers
                        ON customers.id = cart.customer_id
                        JOIN laptops
                        ON laptops.id = cart.product_id
                        JOIN brand
                        ON laptops.brand_id = brand.id;
                """
    end

    def down do
        execute "DROP VIEW checkoutview;"
    end
end
