defmodule Barlix.EAN13 do
  require Integer
  use Bitwise, only_operators: true
  import Integer, only: [mod: 2]

  @moduledoc """
  Implements [EAN13](https://en.wikipedia.org/wiki/International_Article_Number).
  """

  @doc """
  Encodes the given value using EAN13. The given code is validated first.

  ## Examples:

    iex> Barlix.EAN13.encode("5449000096241")
    {:ok, {:D1, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0
    ]}}


    iex> Barlix.EAN13.encode("5901234123450")
    {:error, "validation failed"}

  """
  @spec encode(String.t()) :: {:error, String.t()} | {:ok, Barlix.code()}
  def encode(value) when is_binary(value) and byte_size(value) == 13 do
    case validate(value) do
      :ok -> get_code(value)
      e -> e
    end
  end

  @doc """
  Accepts the same arguments as `encode/1` but raises on error.
  """
  @spec encode!(String.t() | charlist) :: Barlix.code() | no_return
  def encode!(value) when is_binary(value) and byte_size(value) == 13 do
    case encode(value) do
      {:ok, code} -> code
      {:error, error} -> raise Barlix.Error, error
    end
  end

  @doc """
  Validate an EAN13 code.

  ## Examples:

    iex> Barlix.EAN13.validate("5449000096241")
    :ok

    iex> Barlix.EAN13.validate("5901234123450")
    {:error, "validation failed"}
  """
  @spec validate(String.t() | charlist) :: :ok | {:error, String.t()}
  def validate(<<value::binary-size(12), c::binary-size(1)>>) do
    n =
      value
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce(0, fn
        {v, i}, acc when Integer.is_even(i) -> acc + v
        {v, i}, acc when Integer.is_odd(i) -> acc + 3 * v
      end)

    checkdigit = mod(10 - mod(n, 10), 10) |> Integer.to_string()
    if checkdigit == c, do: :ok, else: {:error, "validation failed"}
  end

  @spec get_code(String.t()) :: {:ok, Barlix.code()}
  def get_code(<<p::binary-size(1), l::binary-size(6), r::binary-size(6)>>) do
    prefix = String.to_integer(p)
    encoding = ctbl(prefix)

    left =
      l
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {i, n} ->
        if Integer.is_odd(Enum.at(encoding, n)) do
          lotbl(i)
        else
          letbl(i)
        end
      end)

    right =
      r
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.flat_map(&rtbl/1)

    code =
      pad_left() ++
        guard_left() ++ left ++ guard_center() ++ right ++ guard_right() ++ pad_right()

    {:ok, {:D1, code}}
  end

  defp pad_left, do: List.duplicate(0, 11)
  defp pad_right, do: List.duplicate(0, 7)
  defp guard_left, do: [1, 0, 1]
  defp guard_center, do: [0, 1, 0, 1, 0]
  defp guard_right, do: [1, 0, 1]

  # Encoding tables…

  defp ctbl(0), do: [1, 1, 1, 1, 1, 1]
  defp ctbl(1), do: [1, 1, 2, 1, 2, 2]
  defp ctbl(2), do: [1, 1, 2, 2, 1, 2]
  defp ctbl(3), do: [1, 1, 2, 2, 2, 1]
  defp ctbl(4), do: [1, 2, 1, 1, 2, 2]
  defp ctbl(5), do: [1, 2, 2, 1, 1, 2]
  defp ctbl(6), do: [1, 2, 2, 2, 1, 1]
  defp ctbl(7), do: [1, 2, 1, 2, 1, 2]
  defp ctbl(8), do: [1, 2, 1, 2, 2, 1]
  defp ctbl(9), do: [1, 2, 2, 1, 2, 1]

  defp rtbl(0), do: [1, 1, 1, 0, 0, 1, 0]
  defp rtbl(1), do: [1, 1, 0, 0, 1, 1, 0]
  defp rtbl(2), do: [1, 1, 0, 1, 1, 0, 0]
  defp rtbl(3), do: [1, 0, 0, 0, 0, 1, 0]
  defp rtbl(4), do: [1, 0, 1, 1, 1, 0, 0]
  defp rtbl(5), do: [1, 0, 0, 1, 1, 1, 0]
  defp rtbl(6), do: [1, 0, 1, 0, 0, 0, 0]
  defp rtbl(7), do: [1, 0, 0, 0, 1, 0, 0]
  defp rtbl(8), do: [1, 0, 0, 1, 0, 0, 0]
  defp rtbl(9), do: [1, 1, 1, 0, 1, 0, 0]

  defp lotbl(0), do: [0, 0, 0, 1, 1, 0, 1]
  defp lotbl(1), do: [0, 0, 1, 1, 0, 0, 1]
  defp lotbl(2), do: [0, 0, 1, 0, 0, 1, 1]
  defp lotbl(3), do: [0, 1, 1, 1, 1, 0, 1]
  defp lotbl(4), do: [0, 1, 0, 0, 0, 1, 1]
  defp lotbl(5), do: [0, 1, 1, 0, 0, 0, 1]
  defp lotbl(6), do: [0, 1, 0, 1, 1, 1, 1]
  defp lotbl(7), do: [0, 1, 1, 1, 0, 1, 1]
  defp lotbl(8), do: [0, 1, 1, 0, 1, 1, 1]
  defp lotbl(9), do: [0, 0, 0, 1, 0, 1, 1]

  defp letbl(0), do: [0, 1, 0, 0, 1, 1, 1]
  defp letbl(1), do: [0, 1, 1, 0, 0, 1, 1]
  defp letbl(2), do: [0, 0, 1, 1, 0, 1, 1]
  defp letbl(3), do: [0, 1, 0, 0, 0, 0, 1]
  defp letbl(4), do: [0, 0, 1, 1, 1, 0, 1]
  defp letbl(5), do: [0, 1, 1, 1, 0, 0, 1]
  defp letbl(6), do: [0, 0, 0, 0, 1, 0, 1]
  defp letbl(7), do: [0, 0, 1, 0, 0, 0, 1]
  defp letbl(8), do: [0, 0, 0, 1, 0, 0, 1]
  defp letbl(9), do: [0, 0, 1, 0, 1, 1, 1]
end
