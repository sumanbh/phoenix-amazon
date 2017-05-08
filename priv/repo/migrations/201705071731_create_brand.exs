defmodule Amazon.Repo.Migrations.CreateBrand do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE brand
                (
                    id   SERIAL NOT NULL PRIMARY KEY,
                    name VARCHAR(100)
                );
                """
    end

    def down do
        execute "DROP TABLE brand;"
    end
end
