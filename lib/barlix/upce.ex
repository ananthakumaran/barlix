defmodule Barlix.UPCE do
  @moduledoc """
  Implements [UPC-E](https://en.wikipedia.org/wiki/Universal_Product_Code#UPC-E).
  """

  @doc """
  Encodes the given value using UPC-E. The given code is validated first.

  ## Examples

      iex> Barlix.UPCE.encode("04252614")
      {:ok, {:D1, [
        1, 0, 1,
        0, 0, 1, 1, 1, 0, 1,
        0, 0, 1, 0, 0, 1, 1,
        0, 1, 1, 1, 0, 0, 1,
        0, 0, 1, 1, 0, 1, 1,
        0, 1, 0, 1, 1, 1, 1,
        0, 0, 1, 1, 0, 0, 1,
        0, 1, 0, 1, 0, 1
      ]}}

      iex> Barlix.UPCE.encode("123456")
      {:error, "expected a string with exactly 8 chars, received 6 chars instead"}

      iex> Barlix.UPCE.encode("06543214")
      {:error, "validation failed: expected checksum digit 7 but received 4"}

  """
  @spec encode(String.t()) :: {:error, String.t()} | {:ok, Barlix.code()}
  def encode(value) do
    with {:ok, values} <- validate(value) do
      {:ok, get_code(values)}
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
  Validate an UPC-E code.

  ## Examples

      iex> Barlix.UPCE.validate("04252614")
      {:ok, [0, 4, 2, 5, 2, 6, 1, 4]}

      iex> Barlix.UPCE.validate("123456789")
      {:error, "expected a string with exactly 8 chars, received 9 chars instead"}

      iex> Barlix.UPCE.validate("16543217")
      {:error, "validation failed: expected checksum digit 4 but received 7"}

      iex> Barlix.UPCE.validate(123)
      {:error, "unexpected input"}
  """
  @spec validate(String.t()) :: {:ok, [non_neg_integer()]} | {:error, String.t()}
  def validate(upc_e) when is_binary(upc_e) and byte_size(upc_e) == 8 do
    if String.match?(upc_e, ~r/^\d{8}$/) do
      with {:ok, _ean13_values} <-
             upc_e
             |> to_ean13()
             |> Barlix.EAN13.validate() do
        {:ok,
         upc_e
         |> String.split("", trim: true)
         |> Enum.map(&String.to_integer/1)}
      end
    else
      {:error, "validation failed, string must only contain digits"}
    end
  end

  def validate(s) when is_binary(s) do
    {:error, "expected a string with exactly 8 chars, received #{String.length(s)} chars instead"}
  end

  def validate(_), do: {:error, "unexpected input"}

  defp to_ean13(upc_e) do
    case upc_e do
      <<system, manufacturer::binary-size(2), product::binary-size(3), "0", check_digit>> ->
        <<"0", system, manufacturer::binary, "00000", product::binary, check_digit>>

      <<system, manufacturer::binary-size(2), product::binary-size(3), "1", check_digit>> ->
        <<"0", system, manufacturer::binary, "10000", product::binary, check_digit>>

      <<system, manufacturer::binary-size(2), product::binary-size(3), "2", check_digit>> ->
        <<"0", system, manufacturer::binary, "20000", product::binary, check_digit>>

      <<system, manufacturer::binary-size(3), product::binary-size(2), "3", check_digit>> ->
        <<"0", system, manufacturer::binary, "00000", product::binary, check_digit>>

      <<system, manufacturer::binary-size(4), product, "4", check_digit>> ->
        <<"0", system, manufacturer::binary, "00000", product, check_digit>>

      <<system, manufacturer::binary-size(5), product, check_digit>> ->
        <<"0", system, manufacturer::binary, "0000", product, check_digit>>
    end
  end

  defp get_code(values) do
    {[number_system | digits], [check_digit]} = Enum.split(values, 7)

    encoded_digits =
      digits
      |> Enum.zip(parity_pattern(check_digit, number_system))
      |> Enum.map(fn {digit, encoding_fun} -> encoding_fun.(digit) end)

    {:D1, List.flatten([start_guard(), encoded_digits, end_guard()])}
  end

  defp parity_pattern(check_digit, number_system)

  defp parity_pattern(0, 0), do: [&even/1, &even/1, &even/1, &odd/1, &odd/1, &odd/1]
  defp parity_pattern(1, 0), do: [&even/1, &even/1, &odd/1, &even/1, &odd/1, &odd/1]
  defp parity_pattern(2, 0), do: [&even/1, &even/1, &odd/1, &odd/1, &even/1, &odd/1]
  defp parity_pattern(3, 0), do: [&even/1, &even/1, &odd/1, &odd/1, &odd/1, &even/1]
  defp parity_pattern(4, 0), do: [&even/1, &odd/1, &even/1, &even/1, &odd/1, &odd/1]
  defp parity_pattern(5, 0), do: [&even/1, &odd/1, &odd/1, &even/1, &even/1, &odd/1]
  defp parity_pattern(6, 0), do: [&even/1, &odd/1, &odd/1, &odd/1, &even/1, &even/1]
  defp parity_pattern(7, 0), do: [&even/1, &odd/1, &even/1, &odd/1, &even/1, &odd/1]
  defp parity_pattern(8, 0), do: [&even/1, &odd/1, &even/1, &odd/1, &odd/1, &even/1]
  defp parity_pattern(9, 0), do: [&even/1, &odd/1, &odd/1, &even/1, &odd/1, &even/1]

  defp parity_pattern(0, 1), do: [&odd/1, &odd/1, &odd/1, &even/1, &even/1, &even/1]
  defp parity_pattern(1, 1), do: [&odd/1, &odd/1, &even/1, &odd/1, &even/1, &even/1]
  defp parity_pattern(2, 1), do: [&odd/1, &odd/1, &even/1, &even/1, &odd/1, &even/1]
  defp parity_pattern(3, 1), do: [&odd/1, &odd/1, &even/1, &even/1, &even/1, &odd/1]
  defp parity_pattern(4, 1), do: [&odd/1, &even/1, &odd/1, &odd/1, &even/1, &even/1]
  defp parity_pattern(5, 1), do: [&odd/1, &even/1, &even/1, &odd/1, &odd/1, &even/1]
  defp parity_pattern(6, 1), do: [&odd/1, &even/1, &even/1, &even/1, &odd/1, &odd/1]
  defp parity_pattern(7, 1), do: [&odd/1, &even/1, &odd/1, &even/1, &odd/1, &even/1]
  defp parity_pattern(8, 1), do: [&odd/1, &even/1, &odd/1, &even/1, &even/1, &odd/1]
  defp parity_pattern(9, 1), do: [&odd/1, &even/1, &even/1, &odd/1, &even/1, &odd/1]

  # Encoding tables

  defp start_guard, do: [1, 0, 1]

  defp odd(0), do: [0, 0, 0, 1, 1, 0, 1]
  defp odd(1), do: [0, 0, 1, 1, 0, 0, 1]
  defp odd(2), do: [0, 0, 1, 0, 0, 1, 1]
  defp odd(3), do: [0, 1, 1, 1, 1, 0, 1]
  defp odd(4), do: [0, 1, 0, 0, 0, 1, 1]
  defp odd(5), do: [0, 1, 1, 0, 0, 0, 1]
  defp odd(6), do: [0, 1, 0, 1, 1, 1, 1]
  defp odd(7), do: [0, 1, 1, 1, 0, 1, 1]
  defp odd(8), do: [0, 1, 1, 0, 1, 1, 1]
  defp odd(9), do: [0, 0, 0, 1, 0, 1, 1]

  defp even(0), do: [0, 1, 0, 0, 1, 1, 1]
  defp even(1), do: [0, 1, 1, 0, 0, 1, 1]
  defp even(2), do: [0, 0, 1, 1, 0, 1, 1]
  defp even(3), do: [0, 1, 0, 0, 0, 0, 1]
  defp even(4), do: [0, 0, 1, 1, 1, 0, 1]
  defp even(5), do: [0, 1, 1, 1, 0, 0, 1]
  defp even(6), do: [0, 0, 0, 0, 1, 0, 1]
  defp even(7), do: [0, 0, 1, 0, 0, 0, 1]
  defp even(8), do: [0, 0, 0, 1, 0, 0, 1]
  defp even(9), do: [0, 0, 1, 0, 1, 1, 1]

  defp end_guard, do: [0, 1, 0, 1, 0, 1]
end
