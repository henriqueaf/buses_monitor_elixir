defmodule BusesMonitorElixir.Workers.RequestBrtBusesWorkerTest do
  use ExUnit.Case, async: false

  import Req.Test, only: [json: 2, transport_error: 2]

  alias BusesMonitorElixir.{BrtBusesCache, Workers.RequestBrtBusesWorker}

  setup do
    # Clear any leftover cache data from previous tests
    :ets.delete_all_objects(:brt_buses_cache)
    :ok
  end

  # Pass the plug function directly in req_opts instead of using Req.Test's
  # process-ownership stub registry. This avoids a race condition where the
  # worker (potentially scheduled on a different BEAM scheduler) processes
  # the initial :fetch message before Req.Test.allow/3 can be called.
  defp start_worker(plug_fn) do
    req_opts = [plug: plug_fn, retry: false]

    start_supervised!(%{
      id: RequestBrtBusesWorker,
      start: {RequestBrtBusesWorker, :start, [[request_opts: req_opts]]}
    })
  end

  test "caches buses data on a successful fetch" do
    payload = %{
      "veiculos" => [%{"codigo" => "901008", "linha" => "52", "velocidade" => 23.1}]
    }

    worker_pid = start_worker(fn conn -> json(conn, payload) end)
    # Wait until the worker has finished handling the :fetch message
    :sys.get_state(worker_pid)

    assert {:ok, %{data: ^payload}} = BrtBusesCache.get()
  end

  test "leaves cache empty when the first fetch fails with a transport error" do
    worker_pid = start_worker(fn conn -> transport_error(conn, :econnrefused) end)
    :sys.get_state(worker_pid)

    assert {:error, :empty} = BrtBusesCache.get()
  end

  test "leaves cache empty when the first fetch returns a non-200 status" do
    worker_pid =
      start_worker(fn conn -> Plug.Conn.send_resp(conn, 503, "Service Unavailable") end)

    :sys.get_state(worker_pid)

    assert {:error, :empty} = BrtBusesCache.get()
  end

  test "preserves stale cache when a subsequent fetch fails" do
    initial_payload = %{"veiculos" => [%{"codigo" => "901008"}]}

    # Use an Agent to allow swapping the plug behaviour between fetches.
    # Agent.start_link/1 links to the test process, so it is cleaned up automatically.
    {:ok, mock} = Agent.start_link(fn -> fn conn -> json(conn, initial_payload) end end)

    worker_pid = start_worker(fn conn -> Agent.get(mock, & &1).(conn) end)
    :sys.get_state(worker_pid)

    assert {:ok, %{data: ^initial_payload}} = BrtBusesCache.get()

    # Subsequent fetch fails
    Agent.update(mock, fn _ -> fn conn -> transport_error(conn, :econnrefused) end end)
    send(worker_pid, :fetch)
    :sys.get_state(worker_pid)

    # Cache still holds the previous value
    assert {:ok, %{data: ^initial_payload}} = BrtBusesCache.get()
  end

  test "recovers and updates cache after a previous failed fetch" do
    {:ok, mock} = Agent.start_link(fn -> fn conn -> transport_error(conn, :econnrefused) end end)

    worker_pid = start_worker(fn conn -> Agent.get(mock, & &1).(conn) end)
    :sys.get_state(worker_pid)

    assert {:error, :empty} = BrtBusesCache.get()

    # Next fetch succeeds
    payload = %{"veiculos" => [%{"codigo" => "999"}]}
    Agent.update(mock, fn _ -> fn conn -> json(conn, payload) end end)
    send(worker_pid, :fetch)
    :sys.get_state(worker_pid)

    assert {:ok, %{data: ^payload}} = BrtBusesCache.get()
  end
end
