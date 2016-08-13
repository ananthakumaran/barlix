defmodule Barlix.Code39Test do
  use ExUnit.Case, async: true
  import Barlix.Code39
  import TestUtils
  doctest Barlix.Code39

  test "encode" do
    assert encode!("BARLIX") == s_to_l("1001011011010101101001011011010100101101101010110010101101010011010110100110101001011010110100101101101")
    assert encode!("TEST") == s_to_l("10010110110101010110110010110101100101010110101100101010110110010100101101101")
  end

  test "encode with checksum" do
    assert encode!("BARLIX", checksum: true) == s_to_l("10010110110101011010010110110101001011011010101100101011010100110101101001101010010110101101100101101010100101101101")
    assert encode!("TEST", checksum: true) == s_to_l("100101101101010101101100101101011001010101101011001010101101100101101011001010100101101101")
  end

  test "validation" do
    assert_raise Barlix.Error, fn ->
      encode!("barlix", checksum: true)
    end
  end
end
