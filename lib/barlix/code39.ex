defmodule Barlix.Code39 do
  alias Barlix.Utils

  @moduledoc """
  This module implements the [Code
  39](https://en.wikipedia.org/wiki/Code_39) symbology.
  """

  @doc """
  Encodes the given value using code 39 symbology. Only a subset of
  ascii characters are supported.

  ## Options

  * `:checksum` (boolean) - enables checksum. Defaults to `false`
  """
  @spec encode(String.t() | charlist, Keyword.t()) :: {:error, binary} | {:ok, Barlix.code()}
  def encode(value, options \\ []) do
    Utils.normalize_string(value)
    |> loop(Keyword.get(options, :checksum, false))
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

  defp loop(value, use_checksum) do
    with {:ok, c} <-
           (if use_checksum do
              checksum(value, 0)
            else
              {:ok, []}
            end),
         {:ok, encoded} <- encodings(value, start_symbol()),
         encoded = [[encoded | c] | [0 | stop_symbol()]],
         do: {:ok, {:D1, Utils.flatten(encoded)}}
  end

  defp checksum([], acc) do
    c =
      rem(acc, 43)
      |> index_to_char
      |> encoding

    {:ok, [0 | c]}
  end

  defp checksum([h | t], acc) do
    with i when is_number(i) <- char_to_index(h),
         do: checksum(t, acc + i)
  end

  defp encodings([], acc), do: {:ok, acc}

  defp encodings([h | t], acc) do
    with e when is_list(e) <- encoding(h),
         do: encodings(t, [acc | [0 | e]])
  end

  defp encoding(?0), do: [1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1]
  defp encoding(?1), do: [1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1]
  defp encoding(?2), do: [1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1]
  defp encoding(?3), do: [1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1]
  defp encoding(?4), do: [1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1]
  defp encoding(?5), do: [1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1]
  defp encoding(?6), do: [1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]
  defp encoding(?7), do: [1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]
  defp encoding(?8), do: [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1]
  defp encoding(?9), do: [1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1]
  defp encoding(?A), do: [1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1]
  defp encoding(?B), do: [1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1]
  defp encoding(?C), do: [1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1]
  defp encoding(?D), do: [1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1]
  defp encoding(?E), do: [1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1]
  defp encoding(?F), do: [1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1]
  defp encoding(?G), do: [1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1]
  defp encoding(?H), do: [1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1]
  defp encoding(?I), do: [1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1]
  defp encoding(?J), do: [1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1]
  defp encoding(?K), do: [1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1]
  defp encoding(?L), do: [1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1]
  defp encoding(?M), do: [1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1]
  defp encoding(?N), do: [1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1]
  defp encoding(?O), do: [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1]
  defp encoding(?P), do: [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1]
  defp encoding(?Q), do: [1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1]
  defp encoding(?R), do: [1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1]
  defp encoding(?S), do: [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1]
  defp encoding(?T), do: [1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1]
  defp encoding(?U), do: [1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1]
  defp encoding(?V), do: [1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1]
  defp encoding(?W), do: [1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1]
  defp encoding(?X), do: [1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1]
  defp encoding(?Y), do: [1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1]
  defp encoding(?Z), do: [1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1]
  defp encoding(?-), do: [1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1]
  defp encoding(?.), do: [1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1]
  defp encoding(?\s), do: [1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1]
  defp encoding(?$), do: [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1]
  defp encoding(?/), do: [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1]
  defp encoding(?+), do: [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1]
  defp encoding(?%), do: [1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1]

  defp encoding(invalid),
    do: {:error, "Invalid character found #{IO.chardata_to_string([invalid])}"}

  defp start_symbol, do: [1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1]
  defp stop_symbol, do: start_symbol()

  defp char_to_index(?0), do: 0
  defp char_to_index(?1), do: 1
  defp char_to_index(?2), do: 2
  defp char_to_index(?3), do: 3
  defp char_to_index(?4), do: 4
  defp char_to_index(?5), do: 5
  defp char_to_index(?6), do: 6
  defp char_to_index(?7), do: 7
  defp char_to_index(?8), do: 8
  defp char_to_index(?9), do: 9
  defp char_to_index(?A), do: 10
  defp char_to_index(?B), do: 11
  defp char_to_index(?C), do: 12
  defp char_to_index(?D), do: 13
  defp char_to_index(?E), do: 14
  defp char_to_index(?F), do: 15
  defp char_to_index(?G), do: 16
  defp char_to_index(?H), do: 17
  defp char_to_index(?I), do: 18
  defp char_to_index(?J), do: 19
  defp char_to_index(?K), do: 20
  defp char_to_index(?L), do: 21
  defp char_to_index(?M), do: 22
  defp char_to_index(?N), do: 23
  defp char_to_index(?O), do: 24
  defp char_to_index(?P), do: 25
  defp char_to_index(?Q), do: 26
  defp char_to_index(?R), do: 27
  defp char_to_index(?S), do: 28
  defp char_to_index(?T), do: 29
  defp char_to_index(?U), do: 30
  defp char_to_index(?V), do: 31
  defp char_to_index(?W), do: 32
  defp char_to_index(?X), do: 33
  defp char_to_index(?Y), do: 34
  defp char_to_index(?Z), do: 35
  defp char_to_index(?-), do: 36
  defp char_to_index(?.), do: 37
  defp char_to_index(?\s), do: 38
  defp char_to_index(?$), do: 39
  defp char_to_index(?/), do: 40
  defp char_to_index(?+), do: 41
  defp char_to_index(?%), do: 42

  defp char_to_index(invalid),
    do: {:error, "Invalid character found #{IO.chardata_to_string([invalid])}"}

  defp index_to_char(0), do: ?0
  defp index_to_char(1), do: ?1
  defp index_to_char(2), do: ?2
  defp index_to_char(3), do: ?3
  defp index_to_char(4), do: ?4
  defp index_to_char(5), do: ?5
  defp index_to_char(6), do: ?6
  defp index_to_char(7), do: ?7
  defp index_to_char(8), do: ?8
  defp index_to_char(9), do: ?9
  defp index_to_char(10), do: ?A
  defp index_to_char(11), do: ?B
  defp index_to_char(12), do: ?C
  defp index_to_char(13), do: ?D
  defp index_to_char(14), do: ?E
  defp index_to_char(15), do: ?F
  defp index_to_char(16), do: ?G
  defp index_to_char(17), do: ?H
  defp index_to_char(18), do: ?I
  defp index_to_char(19), do: ?J
  defp index_to_char(20), do: ?K
  defp index_to_char(21), do: ?L
  defp index_to_char(22), do: ?M
  defp index_to_char(23), do: ?N
  defp index_to_char(24), do: ?O
  defp index_to_char(25), do: ?P
  defp index_to_char(26), do: ?Q
  defp index_to_char(27), do: ?R
  defp index_to_char(28), do: ?S
  defp index_to_char(29), do: ?T
  defp index_to_char(30), do: ?U
  defp index_to_char(31), do: ?V
  defp index_to_char(32), do: ?W
  defp index_to_char(33), do: ?X
  defp index_to_char(34), do: ?Y
  defp index_to_char(35), do: ?Z
  defp index_to_char(36), do: ?-
  defp index_to_char(37), do: ?.
  defp index_to_char(38), do: ?\s
  defp index_to_char(39), do: ?$
  defp index_to_char(40), do: ?/
  defp index_to_char(41), do: ?+
  defp index_to_char(42), do: ?%
end
