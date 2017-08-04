defmodule StenoDemo.Web.LayoutView do
  use StenoDemo.Web, :view

  def socket_url(_conn) do
    case Application.get_env(:steno_demo, :env) do
      :prod ->
        "/socket"
      _else ->
        "ws://localhost:8081/socket"
    end
  end
end
