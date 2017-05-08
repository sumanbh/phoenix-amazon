defmodule Amazon.Repo.Migrations.CreateLaptops do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE laptops
                (
                    id              SERIAL NOT NULL PRIMARY KEY,
                    name            VARCHAR(300),
                    os_id           INT NOT NULL REFERENCES os(id),
                    processor_id    INT NOT NULL REFERENCES processor(id),
                    brand_id        INT NOT NULL REFERENCES brand(id),
                    img             VARCHAR(200),
                    ram             VARCHAR (3) NOT NULL,
                    storage_type_id INT NOT NULL REFERENCES storage_type(id),
                    STORAGE         INT,
                    rating          DECIMAL(2, 1),
                    price           NUMERIC(7, 2),
                    img_big         VARCHAR(200),
                    description     TEXT[]
                );
                """
    end

    def down do
        execute "DROP TABLE laptops;"
    end
end
