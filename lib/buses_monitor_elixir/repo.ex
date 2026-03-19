defmodule BusesMonitorElixir.Repo do
  use Ecto.Repo,
    otp_app: :buses_monitor_elixir,
    adapter: Ecto.Adapters.SQLite3
end
