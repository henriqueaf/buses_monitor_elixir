defmodule BusesMonitorElixirWeb.BusesSocket do
  use Phoenix.Socket

  channel "buses_updated_channel", BusesMonitorElixirWeb.BusesChannel

  @impl Phoenix.Socket
  def connect(_params, socket, _connect_info), do: {:ok, socket}

  @impl Phoenix.Socket
  def id(_socket), do: nil
end
