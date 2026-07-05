defmodule BusesMonitorElixirWeb.LocaleController do
  use BusesMonitorElixirWeb, :controller

  alias BusesMonitorElixirWeb.Locale

  @one_year_in_seconds 365 * 24 * 60 * 60

  def update(conn, %{"locale" => locale}) do
    conn =
      if Locale.valid?(locale) do
        put_resp_cookie(conn, "locale", locale,
          max_age: @one_year_in_seconds,
          same_site: "Lax"
        )
      else
        conn
      end

    redirect(conn, to: ~p"/")
  end
end
