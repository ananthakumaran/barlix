defmodule Barlix.EAN13Test do
  use ExUnit.Case, async: true
  alias Barlix.EAN13
  import TestUtils
  doctest Barlix.EAN13

  describe "encode/1" do
    test "for valid number, return code" do
      [
        {"5449000096241",
         "00000000000" <>
           "101" <>
           "010001100111010010111000110100011010100111" <>
           "01010" <>
           "111001011101001010000110110010111001100110" <>
           "101" <>
           "0000000"},

        #   http://www.gomaro.ch/Specifications/EAN13e.htm
        {"7612345678900",
         "00000000000" <>
           "101" <>
           "010111101100110010011010000101000110111001" <>
           "01010" <>
           "101000010001001001000111010011100101110010" <>
           "101" <>
           "0000000"},

        # https://www.dcode.fr/barcode-ean13
        {"3456789543219",
         "00000000000" <>
           "101" <>
           "010001101100010000101001000100010010001011" <>
           "01010" <>
           "100111010111001000010110110011001101110100" <>
           "101" <>
           "0000000"}
      ]
      |> Enum.each(fn {i, e} ->
        expected = s_to_l(e)

        assert EAN13.encode!(i) == expected
      end)
    end

    test "for invalid number, return error" do
      assert_raise Barlix.Error, fn ->
        EAN13.encode!("5901234123450")
      end
    end
  end

  describe "validate/1" do
    test "for valid number, return :ok" do
      assert EAN13.validate("9780306406157") == :ok
      assert EAN13.validate("7311263858981") == :ok
    end

    test "for invalid number, return error" do
      assert EAN13.validate("5901234123450") == {:error, "validation failed"}
    end
  end
end
