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
    {name, worker_opts} = Keyword.pop(opts, :name, __MODULE__)

    # This will call the init() method with opts as parameter
    GenServer.start_link(__MODULE__, worker_opts, name: name)
  end

  # ---------------------------------------------------------------------------
  # GENSERVER CALLBACKS
  # ---------------------------------------------------------------------------

  @impl GenServer
  def init(opts) do
    send(self(), :fetch)
    {:ok, %{request_opts: Keyword.get(opts, :request_opts, [])}}
  end

  @impl GenServer
  def handle_info(:fetch, %{request_opts: request_opts} = state) do
    case BusesMonitorElixir.RequestBrtBuses.call(request_opts) do
      {:ok, body} ->
        BusesMonitorElixir.BrtBusesCache.put(body)
        Logger.info("[RequestBrtBusesWorker] BRT buses data updated successfully.")

      {:error, reason} ->
        Logger.warning(
          "[RequestBrtBusesWorker] Failed to fetch BRT buses data: #{inspect(reason)}"
        )
    end

    Process.send_after(self(), :fetch, @interval)
    {:noreply, state}
  end
end
