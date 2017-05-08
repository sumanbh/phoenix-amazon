defmodule Amazon.Repo.Migrations.CreateProcessor do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE processor
                (
                    id   SERIAL PRIMARY KEY,
                    name VARCHAR(40)
                );
                """
    end

    def down do
        execute "DROP TABLE processor;"
    end
end
