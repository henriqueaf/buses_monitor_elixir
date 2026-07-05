defmodule BusesMonitorElixirWeb.LocaleHook do
  @moduledoc """
  Re-applies the session's locale to Gettext inside the LiveView's own
  process, since Gettext's locale is stored per-process and the connected
  LiveView process is not the same process the `SetLocale` plug ran in.
  """

  import Phoenix.Component, only: [assign: 3]

  alias BusesMonitorElixirWeb.Locale

  def on_mount(:default, _params, session, socket) do
    locale = session["locale"]
    locale = if Locale.valid?(locale), do: locale, else: Locale.default()

    Gettext.put_locale(BusesMonitorElixirWeb.Gettext, locale)

    {:cont, assign(socket, :locale, locale)}
  end
end
