defmodule Barlix.UTF do
  @moduledoc """
  UTF block characters are used to represent bars. This would be
  useful during development as the output can be easily printed on
  standard output.

  ## Example

  ```
  Barlix.Code39.encode!("BARLIX")
  |> Barlix.UTF.print
  |> IO.puts

  ▌▐▐▌█▐▐▐▌▌▐▐▌█▐▐ ▌█▐▌▌▌█ ▌▌█▐▐ █▐▐▌▌▐▌▌▌▐▐▌▌█▐ ▌█▐▌▌
  ```
  """

  @spec print(Barlix.code()) :: iodata
  def print({:D1, list}), do: print1(list)

  defp print1([]), do: ""
  defp print1([0]), do: " "
  defp print1([1]), do: "▌"
  defp print1([1 | [0 | rest]]), do: ["▌", print1(rest)]
  defp print1([1 | [1 | rest]]), do: ["█", print1(rest)]
  defp print1([0 | [1 | rest]]), do: ["▐", print1(rest)]
  defp print1([0 | [0 | rest]]), do: [" ", print1(rest)]
end
