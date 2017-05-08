defmodule Amazon.Repo.Migrations.CreateOrderline do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE orderline
                (
                    id          BIGINT PRIMARY KEY NOT NULL DEFAULT shard_1.id_generator(),
                    order_total NUMERIC(7, 2),
                    customer_id INTEGER NOT NULL REFERENCES customers(id),
                    date_added  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                );
                """
    end

    def down do
        execute "DROP TABLE orderline;"
    end
end
