defmodule BusesMonitorElixir do
  @moduledoc """
  BusesMonitorElixir keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Returns the BRT buses refresh interval in milliseconds, as configured by
  `:request_brt_buses_interval_seconds`.
  """
  def refresh_interval do
    Application.get_env(:buses_monitor_elixir, :request_brt_buses_interval_seconds)
    |> String.to_integer()
    |> :timer.seconds()
  end
end
