defmodule BusesMonitorElixirWeb.BusMapLive do
  use BusesMonitorElixirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        dispatch_event_to_js(socket)
      else
        socket
      end

    Phoenix.PubSub.subscribe(BusesMonitorElixir.PubSub, "buses_updated_channel")
    {:ok, socket}
  end

  @impl true
  def handle_info(:refresh_buses, socket) do
    {:noreply, dispatch_event_to_js(socket)}
  end

  defp dispatch_event_to_js(socket) do
    buses = load_buses()
    push_event(socket, "buses_updated", %{buses: buses})
  end

  defp load_buses do
    case BusesMonitorElixir.BrtBusesCache.get() do
      {:ok, %{data: %{"veiculos" => vehicles}}} -> vehicles
      _ -> []
    end
  end
end
