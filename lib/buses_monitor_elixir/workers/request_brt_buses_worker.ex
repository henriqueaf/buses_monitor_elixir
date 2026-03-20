defmodule BusesMonitorElixir.Workers.RequestBrtBusesWorker do
  @moduledoc """
  Recurring GenServer that fetches BRT buses GPS data every minute and stores
  it in `BusesMonitorElixir.BrtBusesCache`.

  The first fetch is triggered immediately on startup. If a fetch fails the
  error is logged and the previous cached value (if any) is preserved; the
  worker always reschedules the next fetch and never crashes.
  """

  use GenServer

  require Logger

  @interval :timer.minutes(1)

  # ---------------------------------------------------------------------------
  # CLIENT SIDE
  # ---------------------------------------------------------------------------

  def start(opts \\ []) do
    # This will call the init() method with opts as parameter
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # ---------------------------------------------------------------------------
  # GENSERVER CALLBACKS
  # ---------------------------------------------------------------------------

  @impl GenServer
  def init(_opts) do
    send(self(), :fetch)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:fetch, _state) do
    case BusesMonitorElixir.RequestBrtBuses.call() do
      {:ok, body} ->
        BusesMonitorElixir.BrtBusesCache.put(body)
        Logger.info("[RequestBrtBusesWorker] BRT buses data updated successfully.")

      {:error, reason} ->
        Logger.warning(
          "[RequestBrtBusesWorker] Failed to fetch BRT buses data: #{inspect(reason)}"
        )
    end

    Process.send_after(self(), :fetch, @interval)
    {:noreply, %{}}
  end
end
