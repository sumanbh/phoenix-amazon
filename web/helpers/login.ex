defmodule Amazon.Login do
  alias Amazon.{Repo, User}

  def authenticate(email, pwd) do
    user = Repo.get_by(User, email: String.downcase(email))

    case check_password(user, pwd) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  def google(email, id) do
    query = """
            SELECT customers.id, customers.given_name from customers
            WHERE customers.google_id = $1 OR customers.email = $2
            LIMIT 1;
            """
    %{query: query, params: [id, email]}
  end

  def facebook(email, id) do
    query = """
            SELECT customers.id, customers.given_name from customers
            WHERE customers.facebook_id = $1 OR customers.email = $2
            LIMIT 1;
            """
    %{query: query, params: [id, email]}
  end

  defp check_password(user, pwd) do
    case user do
      nil -> Comeonin.Bcrypt.dummy_checkpw()
      _ -> Comeonin.Bcrypt.checkpw(pwd, user.password)
    end
  end
end
