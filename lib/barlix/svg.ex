defmodule Barlix.SVG do
  require EEx

  @moduledoc """
  This module implements the SVG renderer.
  """

  @doc """
  Renders the given code in svg format.

  ## Options

  * `:file` - (path) - target file path. If not set, SVG will be returned as iodata.
  * `:xdim` - (integer) - width of a single bar in pixels. Defaults to `1`.
  * `:height` - (integer) - height of the bar in pixels. Defaults to `100`.
  * `:margin` - (integer) - margin size in pixels. Defaults to `10`.
  """
  @spec print(Barlix.code(), Keyword.t()) :: :ok | {:ok, iodata}
  def print({:D1, code}, options \\ []) do
    xdim = Keyword.get(options, :xdim, 1)
    height = Keyword.get(options, :height, 100)
    margin = Keyword.get(options, :margin, 10)
    svg = svg(code, xdim, height, margin)

    case Keyword.has_key?(options, :file) do
      true -> File.write!(Keyword.fetch!(options, :file), svg)
      false -> {:ok, svg}
    end
  end

  defp svg(code, xdim, height, margin) do
    full_width = xdim * length(code) + margin * 2
    full_height = height + margin * 2

    {_, _, _, bars} =
      Enum.reduce(tl(code) ++ [0], {margin, 1, hd(code), []}, fn
        p, {base, run, p, bars} ->
          {base, run + 1, p, bars}

        0, {base, run, 1, bars} ->
          {base + run * xdim, 1, 0, [{base, margin, run * xdim, height} | bars]}

        1, {base, run, 0, bars} ->
          {base + run * xdim, 1, 1, bars}
      end)

    render(full_width, full_height, Enum.reverse(bars))
  end

  EEx.function_from_file(:defp, :render, Path.join(__DIR__, "svg.eex"), [:width, :height, :bars],
    trim: true
  )
end
