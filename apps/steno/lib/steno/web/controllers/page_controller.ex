defmodule Steno.Web.PageController do
  use Steno.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
