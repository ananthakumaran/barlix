defmodule Barlix.PNGTest do
  use ExUnit.Case, async: true
  alias Barlix.Code39
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
    assert_file_eq('png/code39_barlix.png', png(Code39.encode!("BARLIX")))
    assert_file_eq('png/code39_barlix_height_200.png', png(Code39.encode!("BARLIX"), height: 200))
    assert_file_eq('png/code39_barlix_xdim_3.png', png(Code39.encode!("BARLIX"), xdim: 3))
    assert_file_eq('png/code39_barlix_no_margin.png', png(Code39.encode!("BARLIX"), margin: 0))
    assert_file_eq('png/code39_all_1.png', png(Code39.encode!("0123456789ABCDEFGHIJKL"), xdim: 2))
    assert_file_eq('png/code39_all_2.png', png(Code39.encode!("MNOPQRSTUVWXYZ-. $/+%"), xdim: 2))
  end
end
