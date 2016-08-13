defmodule Barlix.UTF do
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
