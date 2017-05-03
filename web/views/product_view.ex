defmodule Amazon.ProductView do
  use Amazon.Web, :view

  def render("index.json", %{product: product, similar: similar }) do
    %{ product: product, similar: similar }
  end

  def render("error.json", %{errors: errors}) do
    %{ errors: errors }
  end

end
