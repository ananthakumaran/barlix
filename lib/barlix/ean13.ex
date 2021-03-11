defmodule Barlix.EAN13 do
  require Integer
  use Bitwise, only_operators: true
  import Integer, only: [mod: 2]

  @moduledoc """
  Implements [EAN13](https://en.wikipedia.org/wiki/International_Article_Number).
  """

  @multiplier Bitwise.bsl(1, 7)

  @doc """
  Encodes the given value using EAN13. The given code is validated first.

  ## Examples:

    iex> Barlix.EAN13.encode("5449000096241")
    {:ok, {:D1, [
    0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0
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
  def get_code(<<p::binary-size(1), value::binary-size(12)>>) do
    # get the prefix
    prefix = String.to_integer(p)
    # get country encoding
    encoding = country_tbl(prefix)

    parts =
      value
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    left =
      Enum.reduce(0..5, 0, fn i, acc ->
        table = encoding >>> (5 - i) &&& 0x1
        digit = Enum.at(parts, i)
        acc * @multiplier + tbl(table, digit)
      end)
      |> enc_left()

    right =
      Enum.reduce(0..5, 0, fn i, acc ->
        digit = Enum.at(parts, 6 + i)
        acc * @multiplier + tbl(2, digit)
      end)
      |> enc_right()

    code = pad() ++ border() ++ omit_left_zeroes(left) ++ border() ++ right ++ rborder() ++ pad()

    {:ok, {:D1, code}}
  end

  defp pad, do: [0, 0, 0, 0, 0]
  defp rborder, do: [1, 0, 1, 0]
  defp border, do: [0, 1, 0, 1, 0]

  @spec omit_left_zeroes([0 | 1]) :: [0 | 1]
  def omit_left_zeroes([0 | r]), do: omit_left_zeroes(r)
  def omit_left_zeroes([1 | _] = l), do: l

  @spec enc_right(n :: pos_integer()) :: [0 | 1]
  def enc_right(n), do: enc_right(n, [])
  def enc_right(n, list) when n > 0, do: enc_right(floor(n / 2), [mod(n, 2) | list])
  def enc_right(_, list), do: list

  @spec enc_left(pos_integer()) :: [0 | 1]
  def enc_left(n), do: enc_left(n, 0, [])
  defp enc_left(n, i, list) when i <= 42, do: enc_left(floor(n / 2), i + 1, [mod(n, 2) | list])
  defp enc_left(_n, _i, list), do: list

  # Encoding tables…
  defp country_tbl(0), do: 0x0
  defp country_tbl(1), do: 0xB
  defp country_tbl(2), do: 0xD
  defp country_tbl(3), do: 0xE
  defp country_tbl(4), do: 0x13
  defp country_tbl(5), do: 0x19
  defp country_tbl(6), do: 0x1C
  defp country_tbl(7), do: 0x15
  defp country_tbl(8), do: 0x16
  defp country_tbl(9), do: 0x1A

  defp tbl(0, 0), do: 0xD
  defp tbl(0, 1), do: 0x19
  defp tbl(0, 2), do: 0x13
  defp tbl(0, 3), do: 0x3D
  defp tbl(0, 4), do: 0x23
  defp tbl(0, 5), do: 0x31
  defp tbl(0, 6), do: 0x2F
  defp tbl(0, 7), do: 0x3B
  defp tbl(0, 8), do: 0x37
  defp tbl(0, 9), do: 0xB

  defp tbl(1, 0), do: 0x27
  defp tbl(1, 1), do: 0x33
  defp tbl(1, 2), do: 0x1B
  defp tbl(1, 3), do: 0x21
  defp tbl(1, 4), do: 0x1D
  defp tbl(1, 5), do: 0x39
  defp tbl(1, 6), do: 0x5
  defp tbl(1, 7), do: 0x11
  defp tbl(1, 8), do: 0x9
  defp tbl(1, 9), do: 0x17

  defp tbl(2, 0), do: 0x72
  defp tbl(2, 1), do: 0x66
  defp tbl(2, 2), do: 0x6C
  defp tbl(2, 3), do: 0x42
  defp tbl(2, 4), do: 0x5C
  defp tbl(2, 5), do: 0x4E
  defp tbl(2, 6), do: 0x50
  defp tbl(2, 7), do: 0x44
  defp tbl(2, 8), do: 0x48
  defp tbl(2, 9), do: 0x74
end
