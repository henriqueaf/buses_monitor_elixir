defmodule BusesMonitorElixir.RequestBrtBusesTest do
  use ExUnit.Case, async: true
  import Req.Test, only: [stub: 2, json: 2, transport_error: 2]

  alias BusesMonitorElixir.{RequestBrtBuses}

  defp req_opts, do: [plug: {Req.Test, RequestBrtBuses}, retry: false]

  test "returns parsed JSON body on success" do
    payload = %{
      "veiculos" => [
        %{
          "capacidadePeVeiculo" => 0,
          "capacidadeSentadoVeiculo" => 0,
          "codigo" => "901008",
          "dataHora" => 1_773_964_390_000,
          "direcao" => 217,
          "hodometro" => 250_801.8,
          "id_migracao_trajeto" => "9161",
          "ignicao" => 1,
          "latitude" => -22.963287,
          "linha" => "52",
          "longitude" => -43.39382,
          "placa" => "RJN9A01",
          "sentido" => "ida",
          "trajeto" => "52 - T. DEODORO X T. ALVORADA (PARADOR) [IDA]",
          "velocidade" => 23.1
        },
        %{
          "capacidadePeVeiculo" => 0,
          "capacidadeSentadoVeiculo" => 0,
          "codigo" => "901011",
          "dataHora" => 1_773_963_160_000,
          "direcao" => " ",
          "hodometro" => 265_958.4,
          "id_migracao_trajeto" => "8966",
          "ignicao" => 0,
          "latitude" => -22.964608,
          "linha" => "53",
          "longitude" => -43.391601,
          "placa" => "RIV8A74",
          "sentido" => "ida",
          "trajeto" => "53 - SULACAP X ALVORADA (EXPRESSO) [IDA]",
          "velocidade" => 0
        }
      ]
    }

    stub(RequestBrtBuses, fn conn ->
      json(conn, payload)
    end)

    assert {:ok, ^payload} = RequestBrtBuses.call(req_opts())
  end

  test "returns error on non-200 status" do
    stub(RequestBrtBuses, fn conn ->
      Plug.Conn.send_resp(conn, 503, "Service Unavailable")
    end)

    assert {:error, "Unexpected status code: 503"} = RequestBrtBuses.call(req_opts())
  end

  test "returns error on request failure" do
    stub(RequestBrtBuses, fn conn ->
      transport_error(conn, :econnrefused)
    end)

    assert {:error, %Req.TransportError{reason: :econnrefused}} = RequestBrtBuses.call(req_opts())
  end
end
