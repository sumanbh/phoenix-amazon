defmodule Amazon.Repo.Migrations.CreateStorageType do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE storage_type
                (
                    id   SERIAL NOT NULL PRIMARY KEY,
                    name VARCHAR(100)
                );
                """
    end

    def down do
        execute "DROP TABLE storage_type;"
    end
end
