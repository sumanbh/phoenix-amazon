defmodule Amazon.LoginView do
  use Amazon.Web, :view

  def render("show.json", %{jwt: jwt, success: success, cart: cart}) do
    %{
      token: jwt,
      success: success,
      cart: cart
    }
  end

  def render("error.json", _) do
    false
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("forbidden.json", %{error: error}) do
    %{error: error}
  end
end
