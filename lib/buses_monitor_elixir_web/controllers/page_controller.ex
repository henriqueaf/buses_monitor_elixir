defmodule BusesMonitorElixirWeb.PageController do
  use BusesMonitorElixirWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
