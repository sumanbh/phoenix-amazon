defmodule Amazon.Repo.Migrations.Seeds do
    use Ecto.Migration

    def change do
        File.cwd
            |> elem(1)
            |> Path.join("priv/repo/inserts.sql")
            |> Path.expand
            |> File.read
            |> elem(1)
            |> String.split("--statement--")
            |> Enum.each(fn (x) -> execute(x) end)
    end
end
