defmodule Barlix.PNGTest do
  use ExUnit.Case, async: true
  import Barlix.PNG
  import TestUtils
  doctest Barlix.PNG

  def png_file(code, opts \\ []) do
    {:ok, file} = Briefly.create(extname: "svg")
    opts = Keyword.put(opts, :file, file)
    print(code, opts)
    File.read!(file)
  end

  def png_content(code, opts \\ []) do
    {:ok, content} = print(code, opts)
    content
  end

  def assert_png(fixture_file, code, options \\ []) do
    assert_file_eq(fixture_file, png_file(code, options))
    assert_file_eq(fixture_file, png_content(code, options))
  end

  if :erlang.system_info(:otp_release) < ~c"21" do
    @tag :skip
  end

  test "print" do
    assert_png(~c"png/code39_barlix.png", Barlix.Code39.encode!("BARLIX"))

    assert_png(
      ~c"png/code39_barlix_height_200.png",
      Barlix.Code39.encode!("BARLIX"),
      height: 200
    )

    assert_png(
      ~c"png/code39_barlix_xdim_3.png",
      Barlix.Code39.encode!("BARLIX"),
      xdim: 3
    )

    assert_png(
      ~c"png/code39_barlix_no_margin.png",
      Barlix.Code39.encode!("BARLIX"),
      margin: 0
    )

    assert_png(
      ~c"png/code39_all_1.png",
      Barlix.Code39.encode!("0123456789ABCDEFGHIJKL"),
      xdim: 2
    )

    assert_png(
      ~c"png/code39_all_2.png",
      Barlix.Code39.encode!("MNOPQRSTUVWXYZ-. $/+%"),
      xdim: 2
    )

    assert_png(~c"png/code93_barlix.png", Barlix.Code93.encode!("BARLIX"))
    assert_png(~c"png/code93_test93.png", Barlix.Code93.encode!("TEST93"))

    assert_png(
      ~c"png/code93_all_1.png",
      Barlix.Code93.encode!("0123456789ABCDEFGHIJKL"),
      xdim: 2
    )

    assert_png(
      ~c"png/code93_all_2.png",
      Barlix.Code93.encode!("MNOPQRSTUVWXYZ-. $/+%"),
      xdim: 2
    )

    assert_png(
      ~c"png/code93_all_3.png",
      Barlix.Code93.encode!("abcdefghijkl"),
      xdim: 2
    )

    assert_png(~c"png/code128_barlix.png", Barlix.Code128.encode!("BARLIX"), xdim: 2)
    assert_png(~c"png/itf_all.png", Barlix.ITF.encode!("1234567890"), xdim: 1)

    assert_png(
      ~c"png/itf_05012345678900.png",
      Barlix.ITF.encode!("501234567890", checksum: true, pad: true),
      xdim: 1
    )

    assert_png(
      ~c"png/itf_036000291452.png",
      Barlix.ITF.encode!("03600029145", checksum: true, pad: true),
      xdim: 1
    )

    n = 8

    Enum.each(1..(n - 1), fn x ->
      start = div(128, n) * x
      stop = div(128, n) * (x + 1) - 1
      string = Enum.into(start..stop, [])

      assert_png(
        "png/code93_ascii_#{x}.png",
        Barlix.Code93.encode!(string),
        xdim: 2
      )

      assert_png(
        "png/code128_ascii_#{x}.png",
        Barlix.Code128.encode!(string),
        xdim: 2
      )
    end)
  end
end
