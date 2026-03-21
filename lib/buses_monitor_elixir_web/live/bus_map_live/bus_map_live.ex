defmodule BusesMonitorElixirWeb.BusMapLive do
  use BusesMonitorElixirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        dispatch_event(socket)
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, dispatch_event(socket)}
  end

  defp dispatch_event(socket) do
    buses = load_buses()
    Process.send_after(self(), :refresh, BusesMonitorElixir.refresh_interval())
    push_event(socket, "update_buses", %{buses: buses})
  end

  defp load_buses do
    case BusesMonitorElixir.BrtBusesCache.get() do
      {:ok, %{data: %{"veiculos" => vehicles}}} -> vehicles
      _ -> []
    end
  end
end
