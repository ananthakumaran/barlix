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

  @spec print(Barlix.code) :: iodata
  def print([]) do
    ""
  end
  def print([0]), do: " "
  def print([1]), do: "▌"
  def print([1 | [0 | rest]]), do: ["▌", print(rest)]
  def print([1 | [1 | rest]]), do: ["█", print(rest)]
  def print([0 | [1 | rest]]), do: ["▐", print(rest)]
  def print([0 | [0 | rest]]), do: [" ", print(rest)]
end
