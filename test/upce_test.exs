defmodule Barlix.UPCETest do
  use ExUnit.Case, async: true

  import TestUtils

  alias Barlix.UPCE

  doctest Barlix.UPCE

  describe "encode/1" do
    test "for valid number, return code" do
      [
        {"06543217",
         "101" <>
           "0000101" <>
           "0110001" <>
           "0011101" <>
           "0111101" <>
           "0011011" <>
           "0011001" <>
           "010101"},
        {"07811403",
         "101" <>
           "0010001" <>
           "0001001" <>
           "0011001" <>
           "0011001" <>
           "0100011" <>
           "0100111" <>
           "010101"},
        {"07235748",
         "101" <>
           "0010001" <>
           "0010011" <>
           "0100001" <>
           "0110001" <>
           "0111011" <>
           "0011101" <>
           "010101"}
      ]
      |> Enum.each(fn {i, e} ->
        expected = s_to_l(e)

        assert UPCE.encode!(i) == expected
      end)
    end

    test "for invalid number, return error" do
      assert_raise Barlix.Error, fn ->
        UPCE.encode!("123456789")
      end
    end
  end

  describe "validate/1" do
    test "for valid number, return :ok" do
      assert UPCE.validate("07811403") == {:ok, [0, 7, 8, 1, 1, 4, 0, 3]}
      assert UPCE.validate("07235748") == {:ok, [0, 7, 2, 3, 5, 7, 4, 8]}
    end

    test "for invalid number, return error" do
      assert UPCE.validate("04252617") ==
               {:error, "validation failed: expected checksum digit 4 but received 7"}
    end

    test "for wrong input length, return error" do
      assert UPCE.validate("59012341234509876") ==
               {:error, "expected a string with exactly 8 chars, received 17 chars instead"}

      assert UPCE.validate("5901") ==
               {:error, "expected a string with exactly 8 chars, received 4 chars instead"}
    end

    test "for wrong string, return error" do
      assert UPCE.validate("0425x614") ==
               {:error, "validation failed, string must only contain digits"}
    end

    test "for other wrong input, return error" do
      assert UPCE.validate(nil) == {:error, "unexpected input"}
      assert UPCE.validate([]) == {:error, "unexpected input"}
      assert UPCE.validate(%{}) == {:error, "unexpected input"}
    end
  end
end
