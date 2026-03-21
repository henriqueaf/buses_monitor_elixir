defmodule BusesMonitorElixirWeb.PageController do
  use BusesMonitorElixirWeb, :controller

  def home(conn, _params) do
    buses =
      case BusesMonitorElixir.BrtBusesCache.get() do
        {:ok, %{data: %{"veiculos" => vehicles}}} -> vehicles
        _ -> []
      end

    render(conn, :home, buses: buses)
  end
end
