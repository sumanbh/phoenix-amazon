defmodule Amazon.Postgres do
  use Amazon.Web, :model

  alias __MODULE__

  def raw_query(%{query: query, params: params}) do
    {:ok, result} = Ecto.Adapters.SQL.query(Amazon.Repo, query, params)

    result.rows != nil && Enum.map result.rows, fn(row) ->
            Enum.reduce(Enum.zip(result.columns, row), %{}, fn({key, value}, map) ->
            Map.put(map, key, value)
          end)
        end
  end
end
