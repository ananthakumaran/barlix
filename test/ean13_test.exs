defmodule Barlix.EAN13Test do
  use ExUnit.Case, async: true
  alias Barlix.EAN13
  import TestUtils
  doctest Barlix.EAN13

  # use ExCheck

  describe "encode/1" do
    test "for valid number, return code" do
      expected =
        "000000101010001100111010010111000110100011010100111010101110010111010010100001101100101110011001101010"
        |> s_to_l()

      assert EAN13.encode!("5449000096241") == expected
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
