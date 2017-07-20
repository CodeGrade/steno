defmodule StenoDemo.Web.PageController do
  use StenoDemo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
