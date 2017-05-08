defmodule Amazon.Repo.Migrations.CreateOS do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE os
                (
                    id   SERIAL NOT NULL PRIMARY KEY,
                    name VARCHAR(100)
                );
                """
    end

    def down do
        execute "DROP TABLE os;"
    end
end
