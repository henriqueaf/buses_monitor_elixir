defmodule BusesMonitorElixir.BrtBusesCache do
  @moduledoc """
  ETS-backed cache for BRT buses GPS data.

  The ETS table is created and owned by this GenServer process, but
  declared `:public` so `get/0` and `put/1` perform direct ETS operations
  without going through the GenServer process, enabling safe concurrent reads.
  """

  use GenServer

  @table :brt_buses_cache
  @key :buses

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Returns the cached buses data, or `{:error, :empty}` if nothing is cached yet."
  def get do
    case :ets.lookup(@table, @key) do
      [{@key, value}] -> {:ok, value}
      [] -> {:error, :empty}
    end
  end

  @doc "Stores the buses data in the cache, tagging it with the current UTC timestamp."
  def put(data) do
    :ets.insert(@table, {@key, %{data: data, updated_at: DateTime.utc_now()}})
    :ok
  end

  # ---------------------------------------------------------------------------
  # GenServer callbacks
  # ---------------------------------------------------------------------------

  @impl true
  def init(_opts) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, %{}}
  end
end
