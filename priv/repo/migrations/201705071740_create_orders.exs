defmodule Amazon.Repo.Migrations.CreateOrders do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE orders
                (
                    id           SERIAL PRIMARY KEY NOT NULL,
                    orderline_id BIGINT REFERENCES orderline(id),
                    product_id   INTEGER NOT NULL REFERENCES laptops(id),
                    quantity     INTEGER NOT NULL,
                    fullname     VARCHAR(70),
                    address      VARCHAR(32),
                    city         VARCHAR(32),
                    state        CHAR(2),
                    zip          CHAR(5)
                );
                """
    end

    def down do
        execute "DROP TABLE orders;"
    end
end
