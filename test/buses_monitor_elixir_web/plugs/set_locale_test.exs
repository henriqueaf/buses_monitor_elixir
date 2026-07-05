defmodule BusesMonitorElixirWeb.Plugs.SetLocaleTest do
  use BusesMonitorElixirWeb.ConnCase, async: true

  test "GET / with no locale cookie renders in pt_BR (default)", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Ajustar Zoom"
  end

  test "GET / with an en locale cookie renders in English", %{conn: conn} do
    conn =
      conn
      |> put_req_cookie("locale", "en")
      |> get(~p"/")

    assert html_response(conn, 200) =~ "Fit zoom"
  end

  test "GET / with an unsupported locale cookie falls back to pt_BR", %{conn: conn} do
    conn =
      conn
      |> put_req_cookie("locale", "fr")
      |> get(~p"/")

    assert html_response(conn, 200) =~ "Ajustar Zoom"
  end
end
