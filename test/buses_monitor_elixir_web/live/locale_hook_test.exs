defmodule BusesMonitorElixirWeb.LocaleHookTest do
  use BusesMonitorElixirWeb.ConnCase, async: true

  test "connecting with an en locale cookie renders the connected view in English", %{
    conn: conn
  } do
    {:ok, view, _html} =
      conn
      |> put_req_cookie("locale", "en")
      |> live(~p"/")

    assert render(view) =~ "Fit zoom"
  end

  test "connecting with no locale cookie renders the connected view in pt_BR (default)", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/")

    assert render(view) =~ "Ajustar Zoom"
  end
end
