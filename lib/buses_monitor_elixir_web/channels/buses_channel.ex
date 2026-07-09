defmodule BusesMonitorElixirWeb.BusesChannel do
  use Phoenix.Channel

  @impl Phoenix.Channel
  def join("buses_updated_channel", _payload, socket) do
    {:ok, socket}
  end

  @impl Phoenix.Channel
  def handle_info({:refresh_buses, %{buses: buses}}, socket) do
    push(socket, "refresh_buses", %{buses: buses})
    {:noreply, socket}
  end
end
