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
      export default {
        mounted() {
          const map = L.map(this.el).setView([-22.9, -43.2], 12)

          L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: "© <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
            maxZoom: 19
          }).addTo(map)

          let markers = []

          this.handleEvent("update_buses", ({ buses }) => {
            markers.forEach(m => m.remove())
            markers = []
            buses.forEach(bus => {
              if (bus.latitude && bus.longitude) {
                const marker = L.marker([bus.latitude, bus.longitude])
                  .addTo(map)
                  .bindPopup(`<b>Linha ${bus.linha}</b><br>${bus.trajeto}<br>Velocidade: ${bus.velocidade} km/h`)
                markers.push(marker)
              }
            })
          })
        }
      }
    </script>
    """
  end
end
