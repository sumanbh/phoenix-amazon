defmodule Amazon.Google do
  @moduledoc """
  An OAuth2 strategy for Google.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  defp config do
    [strategy: Amazon.Google,
     site: "https://accounts.google.com",
     authorize_url: "/o/oauth2/auth",
     token_url: "/o/oauth2/token"]
  end

  # Public API

  def client do
    Application.get_env(:phoenix_amazon, Amazon.Google)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), params)
  end

  def check_database(id, email) do
    query = """
            SELECT customers.id, customers.given_name from customers
            WHERE customers.google_id = $1 OR customers.email = $2
            LIMIT 1;
            """
    %{query: query, params: [id, email]}
  end

  def insert_user(id, email, name, given_name) do
    query = """
            INSERT INTO customers(google_id, given_name, email, fullname, local) VALUES ($1, $2, $3, $4, $5) RETURNING *;
            """
    %{query: query, params: [id, given_name, email, name, false]}
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
