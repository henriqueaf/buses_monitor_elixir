defmodule BusesMonitorElixirWeb.LocaleTest do
  use ExUnit.Case, async: true

  alias BusesMonitorElixirWeb.Locale

  test "default/0 is pt_BR" do
    assert Locale.default() == "pt_BR"
  end

  test "valid_locales/0 lists pt_BR and en" do
    assert Locale.valid_locales() == ["pt_BR", "en"]
  end

  test "valid?/1 accepts pt_BR and en" do
    assert Locale.valid?("pt_BR")
    assert Locale.valid?("en")
  end

  test "valid?/1 rejects anything else, including nil" do
    refute Locale.valid?("fr")
    refute Locale.valid?(nil)
    refute Locale.valid?("")
  end
end
