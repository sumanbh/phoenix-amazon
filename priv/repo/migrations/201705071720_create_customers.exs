defmodule Amazon.Repo.Migrations.CreateCustomers do
    use Ecto.Migration

    def up do
        execute """
                CREATE TABLE customers
                    (
                    id          SERIAL PRIMARY KEY NOT NULL,
                    google_id   VARCHAR(100),
                    facebook_id VARCHAR(100),
                    given_name  VARCHAR(70),
                    fullname    VARCHAR(70),
                    email       citext UNIQUE,
                    password    VARCHAR(200),
                    phone       VARCHAR(20),
                    address     VARCHAR(32),
                    city        VARCHAR(32),
                    state       CHAR(2),
                    zip         CHAR(5),
                    local       BOOLEAN,
                    date_added  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                    );
                """
    end

    def down do
        execute "DROP TABLE customers;"
    end
end
