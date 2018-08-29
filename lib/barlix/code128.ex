defmodule Barlix.Code128 do
  import Barlix.Utils
  require Barlix.Utils

  @moduledoc """
  This module implements the [Code
  128](https://en.wikipedia.org/wiki/Code_128) symbology.
  """

  @doc """
  Encodes the given value using code 128 symbology.
  """
  @spec encode(String.t() | charlist) :: {:error, binary} | {:ok, Barlix.code()}
  def encode(value) do
    value = normalize_string(value)

    with :ok <- validate(value),
         do: loop(value)
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

  defp validate([h | t]) when h >= 0 and h <= 127 do
    validate(t)
  end

  defp validate([h | _]), do: {:error, "Invalid character found #{IO.chardata_to_string([h])}"}
  defp validate([]), do: :ok

  defmodule State do
    @moduledoc false

    defstruct mode: nil, chars: [], path: []
  end

  defp loop(value) do
    state = Barlix.CostOptimizer.optimize(%State{chars: value}, &next/2, 5)
    codes = :lists.reverse(state.path)

    barcode =
      encodings(codes, append([], quiet()))
      |> append(checksum(codes))
      |> append(stop())
      |> append(quiet())
      |> flatten()

    {:ok, {:D1, barcode}}
  end

  # End
  defp next(%State{mode: :F} = s, cost), do: [{s, cost}]
  defp next(%State{chars: []} = s, cost), do: [{%{s | mode: :F}, cost}]

  # Start
  defp next(%State{mode: nil, chars: [h | _rest]} = s, cost) do
    []
    |> cons_if(
      a?(h),
      {%State{mode: :A, chars: s.chars, path: [index_a(:start_code_a)]}, cost + 1}
    )
    |> cons_if(
      b?(h),
      {%State{mode: :B, chars: s.chars, path: [index_b(:start_code_b)]}, cost + 1}
    )
    |> cons_if(
      c?(s.chars),
      {%State{mode: :C, chars: s.chars, path: [index_c(:start_code_c)]}, cost + 1}
    )
  end

  defp next(%State{mode: :A, chars: [h | rest], path: path} = s, cost) do
    []
    |> cons_if(a?(h), {%State{mode: :A, chars: rest, path: [index_a(h) | path]}, cost + 1})
    |> cons_if(
      !a?(h) && b?(h),
      {%State{mode: :B, chars: rest, path: [index_b(h), index_a(:code_b)] ++ path}, cost + 2}
    )
    |> cons_if(
      !a?(h) && b?(h),
      {%State{mode: :A, chars: rest, path: [index_b(h), index_a(:shift_b)] ++ path}, cost + 2}
    )
    |> cons_if(
      c?(s.chars),
      {%State{
         mode: :C,
         chars: tl(rest),
         path: [index_c([h, hd(rest)]), index_a(:code_c)] ++ path
       }, cost + 2}
    )
  end

  defp next(%State{mode: :B, chars: [h | rest], path: path} = s, cost) do
    []
    |> cons_if(b?(h), {%State{mode: :B, chars: rest, path: [index_b(h) | path]}, cost + 1})
    |> cons_if(
      !b?(h) && a?(h),
      {%State{mode: :A, chars: rest, path: [index_a(h), index_b(:code_a)] ++ path}, cost + 2}
    )
    |> cons_if(
      !b?(h) && a?(h),
      {%State{mode: :B, chars: rest, path: [index_a(h), index_b(:shift_a)] ++ path}, cost + 2}
    )
    |> cons_if(
      c?(s.chars),
      {%State{
         mode: :C,
         chars: tl(rest),
         path: [index_c([h, hd(rest)]), index_b(:code_c)] ++ path
       }, cost + 2}
    )
  end

  defp next(%State{mode: :C, chars: [h | rest], path: path} = s, cost) do
    []
    |> cons_if(
      c?(s.chars),
      {%State{mode: :C, chars: tl(rest), path: [index_c([h, hd(rest)])] ++ path}, cost + 1}
    )
    |> cons_if(
      !c?(s.chars) && a?(h),
      {%State{mode: :A, chars: rest, path: [index_a(h), index_c(:code_a)] ++ path}, cost + 2}
    )
    |> cons_if(
      !c?(s.chars) && b?(h),
      {%State{mode: :B, chars: rest, path: [index_b(h), index_c(:code_b)] ++ path}, cost + 2}
    )
  end

  defp c?([a | [b | _]]) when a >= 48 and a <= 57 and b >= 48 and b <= 57, do: true
  defp c?(_), do: false
  defp a?(x), do: x >= 0 && x <= 95
  defp b?(x), do: x >= 32 && x <= 127

  defp checksum([]), do: []

  defp checksum([start | codes]) do
    sum =
      start * 1 + Enum.reduce(Enum.with_index(codes), 0, fn {x, i}, acc -> x * (i + 1) + acc end)

    rem(sum, 103)
    |> encoding
  end

  defp encodings([n | rest], acc), do: encodings(rest, [acc | encoding(n)])
  defp encodings([], acc), do: acc

  defp quiet, do: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  defp stop, do: [1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1]

  defp index_a(?\s), do: 0
  defp index_a(?!), do: 1
  defp index_a(?"), do: 2
  defp index_a(?#), do: 3
  defp index_a(?$), do: 4
  defp index_a(?%), do: 5
  defp index_a(?&), do: 6
  defp index_a(?'), do: 7
  defp index_a(?(), do: 8
  defp index_a(?)), do: 9
  defp index_a(?*), do: 10
  defp index_a(?+), do: 11
  defp index_a(?,), do: 12
  defp index_a(?-), do: 13
  defp index_a(?.), do: 14
  defp index_a(?/), do: 15
  defp index_a(?0), do: 16
  defp index_a(?1), do: 17
  defp index_a(?2), do: 18
  defp index_a(?3), do: 19
  defp index_a(?4), do: 20
  defp index_a(?5), do: 21
  defp index_a(?6), do: 22
  defp index_a(?7), do: 23
  defp index_a(?8), do: 24
  defp index_a(?9), do: 25
  defp index_a(?:), do: 26
  defp index_a(?;), do: 27
  defp index_a(?<), do: 28
  defp index_a(?=), do: 29
  defp index_a(?>), do: 30
  defp index_a(??), do: 31
  defp index_a(?@), do: 32
  defp index_a(?A), do: 33
  defp index_a(?B), do: 34
  defp index_a(?C), do: 35
  defp index_a(?D), do: 36
  defp index_a(?E), do: 37
  defp index_a(?F), do: 38
  defp index_a(?G), do: 39
  defp index_a(?H), do: 40
  defp index_a(?I), do: 41
  defp index_a(?J), do: 42
  defp index_a(?K), do: 43
  defp index_a(?L), do: 44
  defp index_a(?M), do: 45
  defp index_a(?N), do: 46
  defp index_a(?O), do: 47
  defp index_a(?P), do: 48
  defp index_a(?Q), do: 49
  defp index_a(?R), do: 50
  defp index_a(?S), do: 51
  defp index_a(?T), do: 52
  defp index_a(?U), do: 53
  defp index_a(?V), do: 54
  defp index_a(?W), do: 55
  defp index_a(?X), do: 56
  defp index_a(?Y), do: 57
  defp index_a(?Z), do: 58
  defp index_a(?[), do: 59
  defp index_a(?\\), do: 60
  defp index_a(?]), do: 61
  defp index_a(?^), do: 62
  defp index_a(?_), do: 63
  defp index_a(0), do: 64
  defp index_a(1), do: 65
  defp index_a(2), do: 66
  defp index_a(3), do: 67
  defp index_a(4), do: 68
  defp index_a(5), do: 69
  defp index_a(6), do: 70
  defp index_a(7), do: 71
  defp index_a(8), do: 72
  defp index_a(9), do: 73
  defp index_a(10), do: 74
  defp index_a(11), do: 75
  defp index_a(12), do: 76
  defp index_a(13), do: 77
  defp index_a(14), do: 78
  defp index_a(15), do: 79
  defp index_a(16), do: 80
  defp index_a(17), do: 81
  defp index_a(18), do: 82
  defp index_a(19), do: 83
  defp index_a(20), do: 84
  defp index_a(21), do: 85
  defp index_a(22), do: 86
  defp index_a(23), do: 87
  defp index_a(24), do: 88
  defp index_a(25), do: 89
  defp index_a(26), do: 90
  defp index_a(27), do: 91
  defp index_a(28), do: 92
  defp index_a(29), do: 93
  defp index_a(30), do: 94
  defp index_a(31), do: 95
  defp index_a(:fnc_3), do: 96
  defp index_a(:fnc_2), do: 97
  defp index_a(:shift_b), do: 98
  defp index_a(:code_c), do: 99
  defp index_a(:code_b), do: 100
  defp index_a(:fnc_4), do: 101
  defp index_a(:fnc_1), do: 102
  defp index_a(:start_code_a), do: 103
  defp index_a(:start_code_b), do: 104
  defp index_a(:start_code_c), do: 105

  defp index_b(?\s), do: 0
  defp index_b(?!), do: 1
  defp index_b(?"), do: 2
  defp index_b(?#), do: 3
  defp index_b(?$), do: 4
  defp index_b(?%), do: 5
  defp index_b(?&), do: 6
  defp index_b(?'), do: 7
  defp index_b(?(), do: 8
  defp index_b(?)), do: 9
  defp index_b(?*), do: 10
  defp index_b(?+), do: 11
  defp index_b(?,), do: 12
  defp index_b(?-), do: 13
  defp index_b(?.), do: 14
  defp index_b(?/), do: 15
  defp index_b(?0), do: 16
  defp index_b(?1), do: 17
  defp index_b(?2), do: 18
  defp index_b(?3), do: 19
  defp index_b(?4), do: 20
  defp index_b(?5), do: 21
  defp index_b(?6), do: 22
  defp index_b(?7), do: 23
  defp index_b(?8), do: 24
  defp index_b(?9), do: 25
  defp index_b(?:), do: 26
  defp index_b(?;), do: 27
  defp index_b(?<), do: 28
  defp index_b(?=), do: 29
  defp index_b(?>), do: 30
  defp index_b(??), do: 31
  defp index_b(?@), do: 32
  defp index_b(?A), do: 33
  defp index_b(?B), do: 34
  defp index_b(?C), do: 35
  defp index_b(?D), do: 36
  defp index_b(?E), do: 37
  defp index_b(?F), do: 38
  defp index_b(?G), do: 39
  defp index_b(?H), do: 40
  defp index_b(?I), do: 41
  defp index_b(?J), do: 42
  defp index_b(?K), do: 43
  defp index_b(?L), do: 44
  defp index_b(?M), do: 45
  defp index_b(?N), do: 46
  defp index_b(?O), do: 47
  defp index_b(?P), do: 48
  defp index_b(?Q), do: 49
  defp index_b(?R), do: 50
  defp index_b(?S), do: 51
  defp index_b(?T), do: 52
  defp index_b(?U), do: 53
  defp index_b(?V), do: 54
  defp index_b(?W), do: 55
  defp index_b(?X), do: 56
  defp index_b(?Y), do: 57
  defp index_b(?Z), do: 58
  defp index_b(?[), do: 59
  defp index_b(?\\), do: 60
  defp index_b(?]), do: 61
  defp index_b(?^), do: 62
  defp index_b(?_), do: 63
  defp index_b(?`), do: 64
  defp index_b(?a), do: 65
  defp index_b(?b), do: 66
  defp index_b(?c), do: 67
  defp index_b(?d), do: 68
  defp index_b(?e), do: 69
  defp index_b(?f), do: 70
  defp index_b(?g), do: 71
  defp index_b(?h), do: 72
  defp index_b(?i), do: 73
  defp index_b(?j), do: 74
  defp index_b(?k), do: 75
  defp index_b(?l), do: 76
  defp index_b(?m), do: 77
  defp index_b(?n), do: 78
  defp index_b(?o), do: 79
  defp index_b(?p), do: 80
  defp index_b(?q), do: 81
  defp index_b(?r), do: 82
  defp index_b(?s), do: 83
  defp index_b(?t), do: 84
  defp index_b(?u), do: 85
  defp index_b(?v), do: 86
  defp index_b(?w), do: 87
  defp index_b(?x), do: 88
  defp index_b(?y), do: 89
  defp index_b(?z), do: 90
  defp index_b(?{), do: 91
  defp index_b(?|), do: 92
  defp index_b(?}), do: 93
  defp index_b(?~), do: 94
  defp index_b(127), do: 95
  defp index_b(:fnc_3), do: 96
  defp index_b(:fnc_2), do: 97
  defp index_b(:shift_a), do: 98
  defp index_b(:code_c), do: 99
  defp index_b(:fnc_4), do: 100
  defp index_b(:code_a), do: 101
  defp index_b(:fnc_1), do: 102
  defp index_b(:start_code_a), do: 103
  defp index_b(:start_code_b), do: 104
  defp index_b(:start_code_c), do: 105

  defp index_c([x, y]) when x >= ?0 and x <= ?9 and y >= ?0 and y <= ?9 do
    (x - ?0) * 10 + (y - ?0)
  end

  defp index_c(:code_b), do: 100
  defp index_c(:code_a), do: 101
  defp index_c(:start_code_c), do: 105

  defp encoding(0), do: [1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0]
  defp encoding(1), do: [1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0]
  defp encoding(2), do: [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0]
  defp encoding(3), do: [1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0]
  defp encoding(4), do: [1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0]
  defp encoding(5), do: [1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0]
  defp encoding(6), do: [1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0]
  defp encoding(7), do: [1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0]
  defp encoding(8), do: [1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0]
  defp encoding(9), do: [1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0]
  defp encoding(10), do: [1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0]
  defp encoding(11), do: [1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0]
  defp encoding(12), do: [1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0]
  defp encoding(13), do: [1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0]
  defp encoding(14), do: [1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0]
  defp encoding(15), do: [1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0]
  defp encoding(16), do: [1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0]
  defp encoding(17), do: [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0]
  defp encoding(18), do: [1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0]
  defp encoding(19), do: [1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0]
  defp encoding(20), do: [1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0]
  defp encoding(21), do: [1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0]
  defp encoding(22), do: [1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0]
  defp encoding(23), do: [1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0]
  defp encoding(24), do: [1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0]
  defp encoding(25), do: [1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0]
  defp encoding(26), do: [1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0]
  defp encoding(27), do: [1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0]
  defp encoding(28), do: [1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0]
  defp encoding(29), do: [1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0]
  defp encoding(30), do: [1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0]
  defp encoding(31), do: [1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0]
  defp encoding(32), do: [1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0]
  defp encoding(33), do: [1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0]
  defp encoding(34), do: [1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0]
  defp encoding(35), do: [1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0]
  defp encoding(36), do: [1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0]
  defp encoding(37), do: [1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0]
  defp encoding(38), do: [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0]
  defp encoding(39), do: [1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0]
  defp encoding(40), do: [1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]
  defp encoding(41), do: [1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
  defp encoding(42), do: [1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0]
  defp encoding(43), do: [1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0]
  defp encoding(44), do: [1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0]
  defp encoding(45), do: [1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0]
  defp encoding(46), do: [1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0]
  defp encoding(47), do: [1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0]
  defp encoding(48), do: [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0]
  defp encoding(49), do: [1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0]
  defp encoding(50), do: [1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]
  defp encoding(51), do: [1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0]
  defp encoding(52), do: [1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0]
  defp encoding(53), do: [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0]
  defp encoding(54), do: [1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0]
  defp encoding(55), do: [1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0]
  defp encoding(56), do: [1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0]
  defp encoding(57), do: [1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0]
  defp encoding(58), do: [1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0]
  defp encoding(59), do: [1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0]
  defp encoding(60), do: [1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0]
  defp encoding(61), do: [1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0]
  defp encoding(62), do: [1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0]
  defp encoding(63), do: [1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0]
  defp encoding(64), do: [1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0]
  defp encoding(65), do: [1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]
  defp encoding(66), do: [1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0]
  defp encoding(67), do: [1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0]
  defp encoding(68), do: [1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0]
  defp encoding(69), do: [1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0]
  defp encoding(70), do: [1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0]
  defp encoding(71), do: [1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0]
  defp encoding(72), do: [1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0]
  defp encoding(73), do: [1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0]
  defp encoding(74), do: [1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0]
  defp encoding(75), do: [1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0]
  defp encoding(76), do: [1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0]
  defp encoding(77), do: [1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0]
  defp encoding(78), do: [1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0]
  defp encoding(79), do: [1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0]
  defp encoding(80), do: [1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0]
  defp encoding(81), do: [1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0]
  defp encoding(82), do: [1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0]
  defp encoding(83), do: [1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0]
  defp encoding(84), do: [1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0]
  defp encoding(85), do: [1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0]
  defp encoding(86), do: [1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0]
  defp encoding(87), do: [1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0]
  defp encoding(88), do: [1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0]
  defp encoding(89), do: [1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0]
  defp encoding(90), do: [1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0]
  defp encoding(91), do: [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0]
  defp encoding(92), do: [1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0]
  defp encoding(93), do: [1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0]
  defp encoding(94), do: [1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0]
  defp encoding(95), do: [1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0]
  defp encoding(96), do: [1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0]
  defp encoding(97), do: [1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0]
  defp encoding(98), do: [1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0]
  defp encoding(99), do: [1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0]
  defp encoding(100), do: [1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0]
  defp encoding(101), do: [1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0]
  defp encoding(102), do: [1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0]
  defp encoding(103), do: [1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0]
  defp encoding(104), do: [1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0]
  defp encoding(105), do: [1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0]
end
