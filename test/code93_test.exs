defmodule Barlix.Code93Test do
  use ExUnit.Case, async: true
  import Barlix.Code93
  import TestUtils
  doctest Barlix.Code93

  test "encode" do
    assert encode!("BARLIX") ==
             s_to_l(
               "1010111101101001001101010001101100101010110001011000101011001101101100101011001101010111101"
             )

    assert encode!("TEST") ==
             s_to_l("1010111101101001101100100101101011001101001101000100101010011001010111101")
  end

  test "validation" do
    assert_raise Barlix.Error, fn ->
      encode!("Barlแx")
    end
  end
end
