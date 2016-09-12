defmodule Barlix.PNGTest do
  use ExUnit.Case, async: true
  import Barlix.PNG
  import TestUtils
  doctest Barlix.PNG

  def png(code, opts \\ []) do
    {:ok, file} = Tempfile.random('barlix.png')
    opts = Keyword.put(opts, :file, file)
    print(code, opts)
    File.read!(file)
  end

  test "print" do
    assert_file_eq('png/code39_barlix.png', png(Barlix.Code39.encode!("BARLIX")))
    assert_file_eq('png/code39_barlix_height_200.png', png(Barlix.Code39.encode!("BARLIX"), height: 200))
    assert_file_eq('png/code39_barlix_xdim_3.png', png(Barlix.Code39.encode!("BARLIX"), xdim: 3))
    assert_file_eq('png/code39_barlix_no_margin.png', png(Barlix.Code39.encode!("BARLIX"), margin: 0))
    assert_file_eq('png/code39_all_1.png', png(Barlix.Code39.encode!("0123456789ABCDEFGHIJKL"), xdim: 2))
    assert_file_eq('png/code39_all_2.png', png(Barlix.Code39.encode!("MNOPQRSTUVWXYZ-. $/+%"), xdim: 2))
    assert_file_eq('png/code93_barlix.png', png(Barlix.Code93.encode!("BARLIX")))
    assert_file_eq('png/code93_test93.png', png(Barlix.Code93.encode!("TEST93")))
    assert_file_eq('png/code93_all_1.png', png(Barlix.Code93.encode!("0123456789ABCDEFGHIJKL"), xdim: 2))
    assert_file_eq('png/code93_all_2.png', png(Barlix.Code93.encode!("MNOPQRSTUVWXYZ-. $/+%"), xdim: 2))
    assert_file_eq('png/code93_all_3.png', png(Barlix.Code93.encode!("abcdefghijkl"), xdim: 2))
    n = 8
    Enum.each(1..n-1, fn (x) ->
      start = (div(128, n)) * x
      stop = (div(128, n) * (x + 1)) - 1
      string = (Enum.into(start..stop, []))
      assert_file_eq("png/code93_ascii_#{x}.png", png(Barlix.Code93.encode!(string), xdim: 2))
    end)
  end
end
