defmodule Barlix.PNG do
  @moduledoc """
  This module implements the PNG renderer.
  """
  @white 255
  @black 0

  @doc """
  Renders the given code in png image format.

  ## Options

  * `:file` - (path) - target file path.
  * `:xdim` - (integer) - width of a single bar in pixels. Defaults to `1`.
  * `:height` - (integer) - height of the bar in pixels. Defaults to `100`.
  * `:margin` - (integer) - margin size in pixels. Defaults to `10`.
  """
  @spec print(Barlix.code, Keyword.t) :: :ok
  def print({:D1, code}, options) do
    xdim = Keyword.get(options, :xdim, 1)
    height = Keyword.get(options, :height, 100)
    margin = Keyword.get(options, :margin, 10)
    file_path = Keyword.fetch!(options, :file)
    width = xdim * length(code) + margin * 2
    write_png(file_path, row(code, xdim, margin), width, height, margin)
  end

  defp row(code, xdim, margin) do
    margin_pixels = map_seq(margin, fn (_) -> @white end)
    white = Enum.map(1..xdim, fn(_) -> @white end)
    black = Enum.map(1..xdim, fn(_) -> @black end)
    bar_pixels = Enum.map(code, fn (x) ->
      case x do
        1 -> black
        0 -> white
      end
    end)

    [margin_pixels, bar_pixels, margin_pixels]
  end

  defp write_png(file_path, row, width, height, margin) do
    file = File.open!(file_path, [:write])
    png_options = %{
      size: {width, height + 2 * margin},
      mode: {:grayscale, 8},
      file: file
    }
    png = :png.create(png_options)
    margin_row = map_seq(width, fn (_) -> @white end)
    append_margin_row = fn (_) -> :png.append(png, {:row, margin_row}) end
    _ = map_seq(margin, append_margin_row)
    Enum.each(1..height, fn (_) ->
      :png.append(png, {:row, row})
    end)
    _ = map_seq(margin, append_margin_row)
    :png.close(png)
    :ok = File.close(file)
  end

  defp map_seq(size, callback) do
    if size > 0, do: Enum.map(1..size, fn (x) -> callback.(x) end), else: []
  end
end
