defmodule Amazon.User do
    use Amazon.Web, :model

    @derive {Poison.Encoder, only: [:id, :given_name]}

    schema "customers" do
        field :given_name, :string
        field :fullname, :string
        field :email, :string
        field :password, :string
        field :pass, :string, virtual: true
    end

    @required_fields ~w(given_:given_name fullname email pass)
    @optional_fields ~w(password)

    @doc """
    Creates a changeset based on the `model` and `params`.

    If no params are provided, an invalid changeset is returned
    with no validation performed.
    """
    # def changeset(model, params \\ %{}) do
    #     model
    #     |> cast(params, @required_fields, @optional_fields)
    #     |> validate_format(:email, ~r/@/)
    #     |> validate_length(:pass, min: 5)
    #     |> validate_confirmation(:pass, message: "Password does not match")
    #     |> unique_constraint(:email, message: "Email already taken")
    # end
end
