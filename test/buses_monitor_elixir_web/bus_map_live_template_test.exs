defmodule BusesMonitorElixirWeb.BusMapLiveTemplateTest do
  use BusesMonitorElixirWeb.ConnCase, async: true

  test "renders the language switcher links", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    assert html =~ ~s(href="/locale/pt_BR")
    assert html =~ ~s(href="/locale/en")
  end

  test "renders the JS label data attributes on #bus-map", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    assert html =~ ~s(data-label-line="Linha")
    assert html =~ ~s(data-label-speed="Velocidade")
  end

  test "the root <html> lang attribute follows the selected locale", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)
    assert html =~ ~s(<html lang="pt_BR">)

    html = conn |> put_req_cookie("locale", "en") |> get(~p"/") |> html_response(200)
    assert html =~ ~s(<html lang="en">)
  end
end
