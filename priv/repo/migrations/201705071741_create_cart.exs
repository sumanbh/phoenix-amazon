defmodule Amazon.Repo.Migrations.CreateCart do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE cart
                (
                    id               SERIAL PRIMARY KEY NOT NULL,
                    product_id       INTEGER NOT NULL REFERENCES laptops(id),
                    product_quantity INTEGER NOT NULL,
                    customer_id      INTEGER NOT NULL REFERENCES customers(id),
                    date_added       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
                """
    end

    def down do
        execute "DROP TABLE cart;"
    end
end
