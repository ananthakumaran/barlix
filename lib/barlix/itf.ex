defmodule Barlix.ITF do
  @moduledoc """
  This module implements the [Interleaved 2 of 5 (ITF)](https://en.wikipedia.org/wiki/Interleaved_2_of_5) symbology.
  """
  require Integer
  alias Barlix.Utils

  @doc """
  Encodes the given value using ITF symbology. Only numeric characters
  are supported.

  ## Options

  * `:pad` (boolean) - adds a prefix character `0` if the length of
    characters is not even. Defaults to `false`
  * `:checksum` (boolean) - enables checksum. Defaults to `false`
  """
  @spec encode(String.t() | charlist, Keyword.t()) :: {:error, binary} | {:ok, Barlix.code()}
  def encode(value, options) do
    with {:ok, digits} <- digits(value) do
      checksum(digits, Keyword.get(options, :checksum, false))
      |> pad(Keyword.get(options, :pad, false))
      |> interleave
    end
  end

  @doc """
  Accepts the same arguments as `encode/2`. Returns `t:Barlix.code/0` or
  raises `Barlix.Error` in case of invalid value.
  """
  @spec encode!(String.t() | charlist, Keyword.t()) :: Barlix.code() | no_return
  def encode!(value, options \\ []) do
    case encode(value, options) do
      {:ok, code} -> code
      {:error, error} -> raise Barlix.Error, error
    end
  end

  defp digits(value) do
    Utils.normalize_string(value)
    |> Enum.reverse()
    |> Enum.reduce({:ok, []}, fn
      x, {:ok, digits} when x >= ?0 and x <= ?9 ->
        {:ok, [x - ?0 | digits]}

      _, {:error, _} = error ->
        error

      x, _ ->
        {:error,
         "Invalid character found #{IO.chardata_to_string([x])}. Only numeric characters are allowed"}
    end)
  end

  @black 1
  @white 0

  defp interleave(digits) when Integer.is_even(length(digits)) do
    encoded =
      digits
      |> Enum.chunk_every(2)
      |> Enum.map(fn chunk ->
        Enum.map(chunk, &encode_digit/1)
        |> Enum.map(&String.to_charlist/1)
        |> List.zip()
        |> chunks_to_bars
      end)

    {:ok, {:D1, List.flatten([start_code(), encoded, stop_code()])}}
  end

  defp interleave(digits) do
    {:error, "Even number of digits is required digits: #{inspect(digits)}"}
  end

  defp checksum(digits, false), do: digits

  defp checksum(digits, true) do
    total =
      Enum.with_index(digits)
      |> Enum.reduce(0, fn {digit, i}, total ->
        if Integer.is_even(i) do
          total + 3 * digit
        else
          total + digit
        end
      end)

    c = rem(10 - rem(total, 10), 10)
    digits ++ [c]
  end

  defp pad(digits, true) when Integer.is_odd(length(digits)), do: [0 | digits]
  defp pad(digits, _), do: digits

  defp chunks_to_bars(chunks) do
    Enum.map(chunks, fn {l, r} ->
      [bars(l, @black), bars(r, @white)]
    end)
  end

  defp start_code, do: chunks_to_bars([{?n, ?n}, {?n, ?n}])
  defp stop_code, do: chunks_to_bars([{?W, ?n}]) ++ bars(?n, @black)

  defp encode_digit(0), do: "nnWWn"
  defp encode_digit(1), do: "WnnnW"
  defp encode_digit(2), do: "nWnnW"
  defp encode_digit(3), do: "WWnnn"
  defp encode_digit(4), do: "nnWnW"
  defp encode_digit(5), do: "WnWnn"
  defp encode_digit(6), do: "nWWnn"
  defp encode_digit(7), do: "nnnWW"
  defp encode_digit(8), do: "WnnWn"
  defp encode_digit(9), do: "nWnWn"

  defp bars(?n, @black), do: [@black, @black]
  defp bars(?n, @white), do: [@white, @white]
  defp bars(?W, @black), do: [@black, @black, @black, @black, @black]
  defp bars(?W, @white), do: [@white, @white, @white, @white, @white]
end
