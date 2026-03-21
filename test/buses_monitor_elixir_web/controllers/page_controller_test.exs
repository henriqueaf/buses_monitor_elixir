defmodule BusesMonitorElixirWeb.PageControllerTest do
  use BusesMonitorElixirWeb.ConnCase

  test "GET / renders the bus map page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ~s(id="bus-map")
    assert html_response(conn, 200) =~ "leaflet"
  end
end
