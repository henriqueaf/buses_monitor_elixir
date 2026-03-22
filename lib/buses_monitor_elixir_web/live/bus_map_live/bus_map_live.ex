defmodule BusesMonitorElixirWeb.BusMapLive do
  use BusesMonitorElixirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    refresh_interval_seconds =
      System.convert_time_unit(BusesMonitorElixir.refresh_interval(), :millisecond, :second)

    socket = if connected?(socket), do: dispatch_event_to_js(socket), else: socket

    Phoenix.PubSub.subscribe(BusesMonitorElixir.PubSub, "buses_updated_channel")
    {:ok, assign(socket, :refresh_interval_seconds, refresh_interval_seconds)}
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
