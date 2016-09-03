defmodule Barlix.Utils do
  @moduledoc false

  def flatten(a) do
    do_flatten(a, [])
  end

  defp do_flatten([a | b], acc) when is_list(a) do
    do_flatten(a, b ++ acc)
  end
  defp do_flatten(rest, acc), do: rest ++ acc

end
