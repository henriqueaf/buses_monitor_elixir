defmodule BusesMonitorElixir.RequestBrtBuses do
  @moduledoc """
  Fetches live BRT bus GPS data from Rio de Janeiro's open data API.
  """

  @brt_url "https://dados.mobilidade.rio/gps/brt"

  def call(req_opts \\ []) do
    opts = Keyword.merge([url: @brt_url], req_opts)

    Req.request(opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}), do: {:ok, body}

  defp handle_response({:ok, %Req.Response{status: status}}),
    do: {:error, "Unexpected status code: #{status}"}

  defp handle_response({:error, reason}), do: {:error, reason}
end
