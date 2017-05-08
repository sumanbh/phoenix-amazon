defmodule Amazon.Repo.Migrations.CreateCartView do
    use Ecto.Migration

    def up do
        execute """
                CREATE VIEW cartview
                AS
                    SELECT cart.customer_id,
                            cart.id AS unique_id,
                            cart.product_quantity,
                            laptops.id AS laptops_id,
                            laptops.price,
                            laptops.img,
                            brand.name AS brand_name,
                            laptops.name,
                            cart.date_added
                FROM   cart
                        JOIN laptops
                        ON laptops.id = cart.product_id
                        JOIN brand
                        ON laptops.brand_id = brand.id;
                """
    end

    def down do
        execute "DROP VIEW cartview;"
    end
end
