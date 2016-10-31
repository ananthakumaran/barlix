defmodule Barlix.Code128Test do
  use ExUnit.Case, async: true
  import Barlix.Code128
  import TestUtils
  doctest Barlix.Code128

  use ExCheck

  test "encode" do
    assert encode!("HI345678") == s_to_l("0000000000110100100001100010100011000100010101110111101000101100011100010110110000101001000010011011000111010110000000000")
    assert encode!("TEST") == s_to_l("000000000011010010000110111000101000110100011011101000110111000101100101000011000111010110000000000")
    assert encode!("anotherRATE") == s_to_l("00000000001101001000010010110000110000101001000111101010011110100100110000101011001000010010011110110001011101010001100011011100010100011010001110001101011000111010110000000000")
  end

  test "validation" do
    assert_raise Barlix.Error, fn ->
      encode!("barliÉ")
    end
  end

  @valid_codes Enum.map(0..127, &(<<&1::utf8>>))
  @tag iterations: 500
  property "encodes" do
    for_all lst in list(oneof(@valid_codes)) do
      {x, _} = encode(to_string(lst))
      x == :ok
    end
  end
end
