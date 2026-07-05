defmodule BusesMonitorElixirWeb.Locale do
  @moduledoc """
  Single source of truth for the locales this app supports.
  """

  @default "pt_BR"
  @valid ["pt_BR", "en"]

  @spec default() :: String.t()
  def default, do: @default

  @spec valid_locales() :: [String.t()]
  def valid_locales, do: @valid

  @spec valid?(String.t() | nil) :: boolean()
  def valid?(locale), do: locale in @valid
end
