defmodule Barlix.Code93 do
  import Barlix.Utils

  @moduledoc """
  This module implements the [Code
  93](https://en.wikipedia.org/wiki/Code_93) symbology.
  """

  @doc """
  Encodes the given value using code 93 symbology.
  """
  @spec encode(String.t() | charlist) :: {:error, binary} | {:ok, Barlix.code()}
  def encode(value) do
    normalize_string(value)
    |> Enum.flat_map(&ascii_to_43/1)
    |> loop
  end

  @doc """
  Accepts the same arguments as `encode/1`. Returns `t:Barlix.code/0` or
  raises `Barlix.Error` in case of invalid value.
  """
  @spec encode!(String.t() | charlist) :: Barlix.code() | no_return
  def encode!(value) do
    case encode(value) do
      {:ok, code} -> code
      {:error, error} -> raise Barlix.Error, error
    end
  end

  defp loop(value) do
    with {:ok, c} <- checksum(value) do
      code =
        encodings(value, start_symbol())
        |> append(c)
        |> append(stop_symbol())
        |> append(terminate_symbol())
        |> flatten()

      {:ok, {:D1, code}}
    end
  end

  defp checksum(value), do: checksum(:lists.reverse(value), 0, 0, 0, 1)

  defp checksum([], c, k, _cw, _kw) do
    c = rem(c, 47)
    k = rem(k + c, 47)
    {:ok, encoding(index_to_char(c)) ++ encoding(index_to_char(k))}
  end

  defp checksum([h | t], c, k, cw, kw) do
    with i when is_number(i) <- char_to_index(h) do
      cw = cw + 1
      kw = kw + 1
      checksum(t, c + cw * i, k + kw * i, rem(cw, 20), rem(kw, 15))
    end
  end

  defp encodings([], acc), do: acc
  defp encodings([h | t], acc), do: encodings(t, [acc | encoding(h)])

  @shift_dollar 300
  @shift_percentage 301
  @shift_slash 302
  @shift_plus 303

  defp encoding(?0), do: [1, 0, 0, 0, 1, 0, 1, 0, 0]
  defp encoding(?1), do: [1, 0, 1, 0, 0, 1, 0, 0, 0]
  defp encoding(?2), do: [1, 0, 1, 0, 0, 0, 1, 0, 0]
  defp encoding(?3), do: [1, 0, 1, 0, 0, 0, 0, 1, 0]
  defp encoding(?4), do: [1, 0, 0, 1, 0, 1, 0, 0, 0]
  defp encoding(?5), do: [1, 0, 0, 1, 0, 0, 1, 0, 0]
  defp encoding(?6), do: [1, 0, 0, 1, 0, 0, 0, 1, 0]
  defp encoding(?7), do: [1, 0, 1, 0, 1, 0, 0, 0, 0]
  defp encoding(?8), do: [1, 0, 0, 0, 1, 0, 0, 1, 0]
  defp encoding(?9), do: [1, 0, 0, 0, 0, 1, 0, 1, 0]
  defp encoding(?A), do: [1, 1, 0, 1, 0, 1, 0, 0, 0]
  defp encoding(?B), do: [1, 1, 0, 1, 0, 0, 1, 0, 0]
  defp encoding(?C), do: [1, 1, 0, 1, 0, 0, 0, 1, 0]
  defp encoding(?D), do: [1, 1, 0, 0, 1, 0, 1, 0, 0]
  defp encoding(?E), do: [1, 1, 0, 0, 1, 0, 0, 1, 0]
  defp encoding(?F), do: [1, 1, 0, 0, 0, 1, 0, 1, 0]
  defp encoding(?G), do: [1, 0, 1, 1, 0, 1, 0, 0, 0]
  defp encoding(?H), do: [1, 0, 1, 1, 0, 0, 1, 0, 0]
  defp encoding(?I), do: [1, 0, 1, 1, 0, 0, 0, 1, 0]
  defp encoding(?J), do: [1, 0, 0, 1, 1, 0, 1, 0, 0]
  defp encoding(?K), do: [1, 0, 0, 0, 1, 1, 0, 1, 0]
  defp encoding(?L), do: [1, 0, 1, 0, 1, 1, 0, 0, 0]
  defp encoding(?M), do: [1, 0, 1, 0, 0, 1, 1, 0, 0]
  defp encoding(?N), do: [1, 0, 1, 0, 0, 0, 1, 1, 0]
  defp encoding(?O), do: [1, 0, 0, 1, 0, 1, 1, 0, 0]
  defp encoding(?P), do: [1, 0, 0, 0, 1, 0, 1, 1, 0]
  defp encoding(?Q), do: [1, 1, 0, 1, 1, 0, 1, 0, 0]
  defp encoding(?R), do: [1, 1, 0, 1, 1, 0, 0, 1, 0]
  defp encoding(?S), do: [1, 1, 0, 1, 0, 1, 1, 0, 0]
  defp encoding(?T), do: [1, 1, 0, 1, 0, 0, 1, 1, 0]
  defp encoding(?U), do: [1, 1, 0, 0, 1, 0, 1, 1, 0]
  defp encoding(?V), do: [1, 1, 0, 0, 1, 1, 0, 1, 0]
  defp encoding(?W), do: [1, 0, 1, 1, 0, 1, 1, 0, 0]
  defp encoding(?X), do: [1, 0, 1, 1, 0, 0, 1, 1, 0]
  defp encoding(?Y), do: [1, 0, 0, 1, 1, 0, 1, 1, 0]
  defp encoding(?Z), do: [1, 0, 0, 1, 1, 1, 0, 1, 0]
  defp encoding(?-), do: [1, 0, 0, 1, 0, 1, 1, 1, 0]
  defp encoding(?.), do: [1, 1, 1, 0, 1, 0, 1, 0, 0]
  defp encoding(?\s), do: [1, 1, 1, 0, 1, 0, 0, 1, 0]
  defp encoding(?$), do: [1, 1, 1, 0, 0, 1, 0, 1, 0]
  defp encoding(?/), do: [1, 0, 1, 1, 0, 1, 1, 1, 0]
  defp encoding(?+), do: [1, 0, 1, 1, 1, 0, 1, 1, 0]
  defp encoding(?%), do: [1, 1, 0, 1, 0, 1, 1, 1, 0]
  defp encoding(@shift_dollar), do: [1, 0, 0, 1, 0, 0, 1, 1, 0]
  defp encoding(@shift_percentage), do: [1, 1, 1, 0, 1, 1, 0, 1, 0]
  defp encoding(@shift_slash), do: [1, 1, 1, 0, 1, 0, 1, 1, 0]
  defp encoding(@shift_plus), do: [1, 0, 0, 1, 1, 0, 0, 1, 0]

  defp start_symbol, do: [1, 0, 1, 0, 1, 1, 1, 1, 0]
  defp stop_symbol, do: start_symbol()
  defp terminate_symbol, do: [1]

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
  defp char_to_index(@shift_dollar), do: 43
  defp char_to_index(@shift_percentage), do: 44
  defp char_to_index(@shift_slash), do: 45
  defp char_to_index(@shift_plus), do: 46

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
  defp index_to_char(43), do: @shift_dollar
  defp index_to_char(44), do: @shift_percentage
  defp index_to_char(45), do: @shift_slash
  defp index_to_char(46), do: @shift_plus

  defp ascii_to_43(0), do: [@shift_percentage, ?U]
  defp ascii_to_43(1), do: [@shift_dollar, ?A]
  defp ascii_to_43(2), do: [@shift_dollar, ?B]
  defp ascii_to_43(3), do: [@shift_dollar, ?C]
  defp ascii_to_43(4), do: [@shift_dollar, ?D]
  defp ascii_to_43(5), do: [@shift_dollar, ?E]
  defp ascii_to_43(6), do: [@shift_dollar, ?F]
  defp ascii_to_43(7), do: [@shift_dollar, ?G]
  defp ascii_to_43(8), do: [@shift_dollar, ?H]
  defp ascii_to_43(9), do: [@shift_dollar, ?I]
  defp ascii_to_43(10), do: [@shift_dollar, ?J]
  defp ascii_to_43(11), do: [@shift_dollar, ?K]
  defp ascii_to_43(12), do: [@shift_dollar, ?L]
  defp ascii_to_43(13), do: [@shift_dollar, ?M]
  defp ascii_to_43(14), do: [@shift_dollar, ?N]
  defp ascii_to_43(15), do: [@shift_dollar, ?O]
  defp ascii_to_43(16), do: [@shift_dollar, ?P]
  defp ascii_to_43(17), do: [@shift_dollar, ?Q]
  defp ascii_to_43(18), do: [@shift_dollar, ?R]
  defp ascii_to_43(19), do: [@shift_dollar, ?S]
  defp ascii_to_43(20), do: [@shift_dollar, ?T]
  defp ascii_to_43(21), do: [@shift_dollar, ?U]
  defp ascii_to_43(22), do: [@shift_dollar, ?V]
  defp ascii_to_43(23), do: [@shift_dollar, ?W]
  defp ascii_to_43(24), do: [@shift_dollar, ?X]
  defp ascii_to_43(25), do: [@shift_dollar, ?Y]
  defp ascii_to_43(26), do: [@shift_dollar, ?Z]
  defp ascii_to_43(27), do: [@shift_percentage, ?A]
  defp ascii_to_43(28), do: [@shift_percentage, ?B]
  defp ascii_to_43(29), do: [@shift_percentage, ?C]
  defp ascii_to_43(30), do: [@shift_percentage, ?D]
  defp ascii_to_43(31), do: [@shift_percentage, ?E]
  defp ascii_to_43(32), do: [?\s]
  defp ascii_to_43(33), do: [@shift_slash, ?A]
  defp ascii_to_43(34), do: [@shift_slash, ?B]
  defp ascii_to_43(35), do: [@shift_slash, ?C]
  defp ascii_to_43(36), do: [?$]
  defp ascii_to_43(37), do: [?%]
  defp ascii_to_43(38), do: [@shift_slash, ?F]
  defp ascii_to_43(39), do: [@shift_slash, ?G]
  defp ascii_to_43(40), do: [@shift_slash, ?H]
  defp ascii_to_43(41), do: [@shift_slash, ?I]
  defp ascii_to_43(42), do: [@shift_slash, ?J]
  defp ascii_to_43(43), do: [?+]
  defp ascii_to_43(44), do: [@shift_slash, ?L]
  defp ascii_to_43(45), do: [?-]
  defp ascii_to_43(46), do: [?.]
  defp ascii_to_43(47), do: [?/]
  defp ascii_to_43(48), do: [?0]
  defp ascii_to_43(49), do: [?1]
  defp ascii_to_43(50), do: [?2]
  defp ascii_to_43(51), do: [?3]
  defp ascii_to_43(52), do: [?4]
  defp ascii_to_43(53), do: [?5]
  defp ascii_to_43(54), do: [?6]
  defp ascii_to_43(55), do: [?7]
  defp ascii_to_43(56), do: [?8]
  defp ascii_to_43(57), do: [?9]
  defp ascii_to_43(58), do: [@shift_slash, ?Z]
  defp ascii_to_43(59), do: [@shift_percentage, ?F]
  defp ascii_to_43(60), do: [@shift_percentage, ?G]
  defp ascii_to_43(61), do: [@shift_percentage, ?H]
  defp ascii_to_43(62), do: [@shift_percentage, ?I]
  defp ascii_to_43(63), do: [@shift_percentage, ?J]
  defp ascii_to_43(64), do: [@shift_percentage, ?V]
  defp ascii_to_43(65), do: [?A]
  defp ascii_to_43(66), do: [?B]
  defp ascii_to_43(67), do: [?C]
  defp ascii_to_43(68), do: [?D]
  defp ascii_to_43(69), do: [?E]
  defp ascii_to_43(70), do: [?F]
  defp ascii_to_43(71), do: [?G]
  defp ascii_to_43(72), do: [?H]
  defp ascii_to_43(73), do: [?I]
  defp ascii_to_43(74), do: [?J]
  defp ascii_to_43(75), do: [?K]
  defp ascii_to_43(76), do: [?L]
  defp ascii_to_43(77), do: [?M]
  defp ascii_to_43(78), do: [?N]
  defp ascii_to_43(79), do: [?O]
  defp ascii_to_43(80), do: [?P]
  defp ascii_to_43(81), do: [?Q]
  defp ascii_to_43(82), do: [?R]
  defp ascii_to_43(83), do: [?S]
  defp ascii_to_43(84), do: [?T]
  defp ascii_to_43(85), do: [?U]
  defp ascii_to_43(86), do: [?V]
  defp ascii_to_43(87), do: [?W]
  defp ascii_to_43(88), do: [?X]
  defp ascii_to_43(89), do: [?Y]
  defp ascii_to_43(90), do: [?Z]
  defp ascii_to_43(91), do: [@shift_percentage, ?K]
  defp ascii_to_43(92), do: [@shift_percentage, ?L]
  defp ascii_to_43(93), do: [@shift_percentage, ?M]
  defp ascii_to_43(94), do: [@shift_percentage, ?N]
  defp ascii_to_43(95), do: [@shift_percentage, ?O]
  defp ascii_to_43(96), do: [@shift_percentage, ?W]
  defp ascii_to_43(97), do: [@shift_plus, ?A]
  defp ascii_to_43(98), do: [@shift_plus, ?B]
  defp ascii_to_43(99), do: [@shift_plus, ?C]
  defp ascii_to_43(100), do: [@shift_plus, ?D]
  defp ascii_to_43(101), do: [@shift_plus, ?E]
  defp ascii_to_43(102), do: [@shift_plus, ?F]
  defp ascii_to_43(103), do: [@shift_plus, ?G]
  defp ascii_to_43(104), do: [@shift_plus, ?H]
  defp ascii_to_43(105), do: [@shift_plus, ?I]
  defp ascii_to_43(106), do: [@shift_plus, ?J]
  defp ascii_to_43(107), do: [@shift_plus, ?K]
  defp ascii_to_43(108), do: [@shift_plus, ?L]
  defp ascii_to_43(109), do: [@shift_plus, ?M]
  defp ascii_to_43(110), do: [@shift_plus, ?N]
  defp ascii_to_43(111), do: [@shift_plus, ?O]
  defp ascii_to_43(112), do: [@shift_plus, ?P]
  defp ascii_to_43(113), do: [@shift_plus, ?Q]
  defp ascii_to_43(114), do: [@shift_plus, ?R]
  defp ascii_to_43(115), do: [@shift_plus, ?S]
  defp ascii_to_43(116), do: [@shift_plus, ?T]
  defp ascii_to_43(117), do: [@shift_plus, ?U]
  defp ascii_to_43(118), do: [@shift_plus, ?V]
  defp ascii_to_43(119), do: [@shift_plus, ?W]
  defp ascii_to_43(120), do: [@shift_plus, ?X]
  defp ascii_to_43(121), do: [@shift_plus, ?Y]
  defp ascii_to_43(122), do: [@shift_plus, ?Z]
  defp ascii_to_43(123), do: [@shift_percentage, ?P]
  defp ascii_to_43(124), do: [@shift_percentage, ?Q]
  defp ascii_to_43(125), do: [@shift_percentage, ?R]
  defp ascii_to_43(126), do: [@shift_percentage, ?S]
  defp ascii_to_43(127), do: [@shift_percentage, ?T]
  defp ascii_to_43(unknown), do: [unknown]
end
