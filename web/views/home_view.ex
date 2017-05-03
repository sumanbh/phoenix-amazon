defmodule Amazon.HomeView do
  use Amazon.Web, :view

  def render("index.json", %{total: total, data: data }) do
    %{total: total, data: data }
  end

end
