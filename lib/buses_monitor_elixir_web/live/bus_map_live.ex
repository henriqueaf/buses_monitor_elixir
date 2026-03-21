defmodule BusesMonitorElixirWeb.BusMapLive do
  use BusesMonitorElixirWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        buses = load_buses()
        Process.send_after(self(), :refresh, BusesMonitorElixir.refresh_interval())
        push_event(socket, "update_buses", %{buses: buses})
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_info(:refresh, socket) do
    buses = load_buses()
    Process.send_after(self(), :refresh, BusesMonitorElixir.refresh_interval())
    {:noreply, push_event(socket, "update_buses", %{buses: buses})}
  end

  defp load_buses do
    case BusesMonitorElixir.BrtBusesCache.get() do
      {:ok, %{data: %{"veiculos" => vehicles}}} -> vehicles
      _ -> []
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div
      id="bus-map"
      style="position: fixed; inset: 0; z-index: 0;"
      phx-hook=".BusMap"
      phx-update="ignore"
    >
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".BusMap">
      const RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

      const handleBusesUpdated = (buses, markers, map) => {
        if (!buses || buses.length === 0) return;

        markers.forEach(m => m.remove());

        const filteredBusArray = filterBusesWithEngineOn(buses);
        createBusMarkers(filteredBusArray, markers, map);
      }

      const filterBusesWithEngineOn = (buses) => {
        return buses.filter(bus => bus.ignicao === 1);
      }

      const createBusMarkers = (buses, markers, map) => {
        markers = [];

        buses.forEach(bus => {
          const marker = L.marker([bus.latitude, bus.longitude])
            .addTo(map)
            .bindPopup(`<b>Linha ${bus.linha}</b><br>${bus.trajeto}<br>Velocidade: ${bus.velocidade} km/h`)

          markers.push(marker);
        });
      }

      export default {
        mounted() {
          const map = L.map(this.el).setView(RIO_DE_JANEIRO_COORDINATES, 11)

          L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "© <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
            maxZoom: 19
          }).addTo(map)

          let markers = []

          this.handleEvent("update_buses", ({ buses }) => {
            handleBusesUpdated(buses, markers, map)
          })
        }
      }
    </script>
    """
  end
end
