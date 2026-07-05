defmodule BusesMonitorElixirWeb.Plugs.SetLocale do
  @moduledoc """
  Reads the `locale` cookie and applies it as the Gettext locale for the
  current process, falling back to the default locale when the cookie is
  missing or holds an unsupported value.
  """

  import Plug.Conn

  alias BusesMonitorElixirWeb.Locale

  def init(opts), do: opts

  def call(conn, _opts) do
    locale =
      conn.cookies["locale"]
      |> case do
        value when is_binary(value) -> value
        _ -> nil
      end

    locale = if Locale.valid?(locale), do: locale, else: Locale.default()

    Gettext.put_locale(BusesMonitorElixirWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end
end
