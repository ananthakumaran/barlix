defmodule Barlix.EAN13Test do
  use ExUnit.Case, async: true
  alias Barlix.EAN13
  import TestUtils
  doctest Barlix.EAN13

  describe "encode/1" do
    test "for valid number, return code" do
      [
        {"5449000096241",
         "101" <>
           "010001100111010010111000110100011010100111" <>
           "01010" <>
           "111001011101001010000110110010111001100110" <>
           "101"},

        #   http://www.gomaro.ch/Specifications/EAN13e.htm
        {"7612345678900",
         "101" <>
           "010111101100110010011010000101000110111001" <>
           "01010" <>
           "101000010001001001000111010011100101110010" <>
           "101"},

        # https://www.dcode.fr/barcode-ean13
        {"3456789543219",
         "101" <>
           "010001101100010000101001000100010010001011" <>
           "01010" <>
           "100111010111001000010110110011001101110100" <>
           "101"}
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
      assert EAN13.validate("9780306406157") == {:ok, [9, 7, 8, 0, 3, 0, 6, 4, 0, 6, 1, 5, 7]}
      assert EAN13.validate("7311263858981") == {:ok, [7, 3, 1, 1, 2, 6, 3, 8, 5, 8, 9, 8, 1]}
    end

    test "for invalid number, return error" do
      assert EAN13.validate("5901234123450") ==
               {:error, "validation failed: expected checksum digit 7 but received 0"}
    end

    test "for wrong input length, return error" do
      assert EAN13.validate("59012341234509876") ==
               {:error, "expected a string with exactly 13 chars, received 17 chars instead"}

      assert EAN13.validate("5901") ==
               {:error, "expected a string with exactly 13 chars, received 4 chars instead"}
    end

    test "for wrong string, return error" do
      assert EAN13.validate("9780306x06157") ==
               {:error, "validation failed, string must only contain digits"}
    end

    test "for other wrong input, return error" do
      assert EAN13.validate(nil) == {:error, "unexpected input"}
      assert EAN13.validate([]) == {:error, "unexpected input"}
      assert EAN13.validate(%{}) == {:error, "unexpected input"}
    end
  end
end
