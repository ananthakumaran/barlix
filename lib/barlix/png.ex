defmodule Barlix.PNG do
  @moduledoc """
  This module implements the PNG renderer.
  """
  @white 255
  @black 0

  @doc """
  Renders the given code in png image format.

  ## Options

  * `:file` - (path) - target file path. If not set, PNG will be returned as iodata.
  * `:xdim` - (integer) - width of a single bar in pixels. Defaults to `1`.
  * `:height` - (integer) - height of the bar in pixels. Defaults to `100`.
  * `:margin` - (integer) - margin size in pixels. Defaults to `10`.
  """
  @spec print(Barlix.code(), Keyword.t()) :: :ok | {:ok, iodata}
  def print({:D1, code}, options \\ []) do
    xdim = Keyword.get(options, :xdim, 1)
    height = Keyword.get(options, :height, 100)
    margin = Keyword.get(options, :margin, 10)
    width = xdim * length(code) + margin * 2
    row = row(code, xdim, margin)

    case Keyword.has_key?(options, :file) do
      true -> print_to_file(Keyword.fetch!(options, :file), row, width, height, margin)
      false -> print_to_memory(row, width, height, margin)
    end
  end

  defp row(code, xdim, margin) do
    margin_pixels = map_seq(margin, fn _ -> @white end)
    white = Enum.map(1..xdim, fn _ -> @white end)
    black = Enum.map(1..xdim, fn _ -> @black end)

    bar_pixels =
      Enum.map(code, fn x ->
        case x do
          1 -> black
          0 -> white
        end
      end)

    [margin_pixels, bar_pixels, margin_pixels]
  end

  defp print_to_file(file_path, row, width, height, margin) do
    file = File.open!(file_path, [:write])
    write_png(row, width, height, margin, file: file)
    :ok = File.close(file)
  end

  defp print_to_memory(row, width, height, margin) do
    {:ok, storage} = start_storage()
    write_png(row, width, height, margin, call: &save_chunk(storage, &1))
    release_storage(storage)
  end

  defp write_png(row, width, height, margin, options) do
    png_options = %{
      size: {width, height + 2 * margin},
      mode: {:grayscale, 8}
    }

    png = :png.create(Enum.into(options, png_options))
    margin_row = map_seq(width, fn _ -> @white end)
    append_margin_row = fn _ -> :png.append(png, {:row, margin_row}) end
    _ = map_seq(margin, append_margin_row)

    Enum.each(1..height, fn _ ->
      :png.append(png, {:row, row})
    end)

    _ = map_seq(margin, append_margin_row)
    :png.close(png)
  end

  defp map_seq(size, callback) do
    if size > 0, do: Enum.map(1..size, fn x -> callback.(x) end), else: []
  end

  defp start_storage, do: Agent.start_link(fn -> [] end)

  defp save_chunk(storage, iodata) do
    Agent.update(storage, fn acc -> [acc, iodata] end)
  end

  defp release_storage(storage) do
    iodata = Agent.get(storage, & &1)
    :ok = Agent.stop(storage)
    {:ok, iodata}
  end
end
