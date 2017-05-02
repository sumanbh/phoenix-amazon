defmodule Amazon.PageController do
  use Amazon.Web, :controller

  def index(conn, _params) do
    render conn, "/index.html"
  end
end
