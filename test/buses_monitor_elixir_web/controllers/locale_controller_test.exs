defmodule BusesMonitorElixirWeb.LocaleControllerTest do
  use BusesMonitorElixirWeb.ConnCase, async: true

  test "GET /locale/en sets the locale cookie and redirects to /", %{conn: conn} do
    conn = get(conn, ~p"/locale/en")

    assert redirected_to(conn) == ~p"/"
    assert conn.resp_cookies["locale"].value == "en"
  end

  test "GET /locale/pt_BR sets the locale cookie and redirects to /", %{conn: conn} do
    conn = get(conn, ~p"/locale/pt_BR")

    assert redirected_to(conn) == ~p"/"
    assert conn.resp_cookies["locale"].value == "pt_BR"
  end

  test "GET /locale/fr (unsupported) redirects without setting a cookie", %{conn: conn} do
    conn = get(conn, ~p"/locale/fr")

    assert redirected_to(conn) == ~p"/"
    refute Map.has_key?(conn.resp_cookies, "locale")
  end
end
