defmodule Barlix.SVGTest do
  use ExUnit.Case, async: true
  import Barlix.SVG
  import TestUtils

  def svg_file(code, opts \\ []) do
    {:ok, file} = Briefly.create(extname: "svg")
    opts = Keyword.put(opts, :file, file)
    print(code, opts)
    File.read!(file)
  end

  def svg_content(code, opts \\ []) do
    {:ok, content} = print(code, opts)
    content
  end

  def assert_svg(fixture_file, code, options \\ []) do
    assert_file_eq(fixture_file, svg_file(code, options))
    assert_file_eq(fixture_file, svg_content(code, options))
  end

  test "print" do
    assert_svg("svg/code39_barlix.svg", Barlix.Code39.encode!("BARLIX"))

    assert_svg(
      "svg/code39_barlix_height_200.svg",
      Barlix.Code39.encode!("BARLIX"),
      height: 200
    )

    assert_svg(
      "svg/code39_barlix_xdim_3.svg",
      Barlix.Code39.encode!("BARLIX"),
      xdim: 3
    )

    assert_svg(
      "svg/code39_barlix_no_margin.svg",
      Barlix.Code39.encode!("BARLIX"),
      margin: 0
    )

    assert_svg(
      "svg/code39_all_1.svg",
      Barlix.Code39.encode!("0123456789ABCDEFGHIJKL"),
      xdim: 2
    )

    assert_svg(
      "svg/code39_all_2.svg",
      Barlix.Code39.encode!("MNOPQRSTUVWXYZ-. $/+%"),
      xdim: 2
    )
  end
end
