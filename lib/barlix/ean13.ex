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
    1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1
    ]}}


    iex> Barlix.EAN13.encode("5901234123450")
    {:error, "validation failed: expected checksum digit 7 but received 0"}

  """
  @spec encode(String.t()) :: {:error, String.t()} | {:ok, Barlix.code()}
  def encode(value) do
    case validate(value) do
      {:ok, values} -> get_code(values)
      e -> e
    end
  end

  @doc """
  Accepts the same arguments as `encode/1` but raises on error.
  """
  @spec encode!(String.t()) :: Barlix.code() | no_return
  def encode!(value) do
    case encode(value) do
      {:ok, code} -> code
      {:error, error} -> raise Barlix.Error, error
    end
  end

  @doc """
  Validate an EAN13 code.

  ## Examples:

    iex> Barlix.EAN13.validate("5449000096241")
    {:ok, [5, 4, 4, 9, 0, 0, 0, 0, 9, 6, 2, 4, 1]}

    iex> Barlix.EAN13.validate("5901234123450")
    {:error, "validation failed: expected checksum digit 7 but received 0"}
  """
  @spec validate(String.t()) :: {:ok, [non_neg_integer()]} | {:error, String.t()}
  def validate(v) when is_binary(v) and byte_size(v) == 13 do
    if String.match?(v, ~r/^\d{13}$/) == false do
      {:error, "validation failed, string must only contain digits"}
    else
      value =
        String.split(v, "", trim: true)
        |> Enum.map(&String.to_integer/1)

      {data, [c]} = Enum.split(value, 12)

      n =
        data
        |> Enum.with_index()
        |> Enum.reduce(0, fn
          {v, i}, acc when Integer.is_even(i) -> acc + v
          {v, i}, acc when Integer.is_odd(i) -> acc + 3 * v
        end)

      checkdigit = mod(10 - mod(n, 10), 10)
      validate_checksum(checkdigit, c, value)
    end
  end

  def validate(s) when is_binary(s),
    do:
      {:error,
       "expected a string with exactly 13 chars, received #{String.length(s)} chars instead"}

  def validate(_), do: {:error, "unexpected input"}

  defp validate_checksum(checkdigit, checkdigit, values), do: {:ok, values}

  defp validate_checksum(ours, theirs, _values),
    do: {:error, "validation failed: expected checksum digit #{ours} but received #{theirs}"}

  @spec get_code([non_neg_integer()]) :: {:ok, Barlix.code()}
  def get_code(values) when is_list(values) do
    {[p | l], r} = Enum.split(values, 7)
    get_code(p, l, r)
  end

  @spec get_code(non_neg_integer(), [non_neg_integer()], [non_neg_integer()]) ::
          {:ok, Barlix.code()}
  def get_code(prefix, l, r) when is_integer(prefix) and is_list(l) and is_list(r) do
    encoding = ctbl(prefix)

    left =
      l
      |> Enum.with_index()
      |> Enum.flat_map(fn {i, n} ->
        if Integer.is_odd(Enum.at(encoding, n)) do
          lotbl(i)
        else
          letbl(i)
        end
      end)

    right = Enum.flat_map(r, &rtbl/1)

    code =
      [guard_left(), left, guard_center(), right, guard_right()]
      |> List.flatten()

    {:ok, {:D1, code}}
  end

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
