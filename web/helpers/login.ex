defmodule Amazon.Login do
  alias Amazon.{Repo, User}

  def authenticate(email, pwd) do
    user = Repo.get_by(User, email: String.downcase(email))

    case check_password(user, pwd) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  defp check_password(user, pwd) do
    case user do
      nil -> Comeonin.Bcrypt.dummy_checkpw()
      _ -> Comeonin.Bcrypt.checkpw(pwd, user.password)
    end
  end
end
