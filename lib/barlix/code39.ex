defmodule Barlix.Code39 do
  def encode(value, options \\ []) do
    value = if is_binary(value) do
      String.to_charlist(value)
    else
      value
    end
    loop(value, Keyword.get(options, :checksum, false))
  end

  def loop(value, use_checksum) do
    with encoded = stop_symbol,
         {:ok, c} <- (if use_checksum do
           checksum(value, 0)
         else
           {:ok, []}
         end),
         encoded = start_symbol,
         {:ok, encoded} <- encodings(value, encoded),
      do: stop_symbol ++ c ++ [0 | encoded] |> :lists.reverse
  end

  def checksum([], acc) do
    c = rem(acc, 43)
    |> index_to_char
    |> encoding
    {:ok, [0 | c]}
  end
  def checksum([h|t], acc) do
    with i when is_number(i) <- encoding_index(h),
      do: checksum(t, acc + i)
  end

  def encodings([], acc), do: {:ok, acc}
  def encodings([h|t], acc) do
    with e when is_list(e) <- encoding(h),
      do: encodings(t, e ++ [0 | acc])
  end

  def encoding(?0), do: [1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1]
  def encoding(?1), do: [1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1]
  def encoding(?2), do: [1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1]
  def encoding(?3), do: [1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1]
  def encoding(?4), do: [1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1]
  def encoding(?5), do: [1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1]
  def encoding(?6), do: [1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1]
  def encoding(?7), do: [1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1]
  def encoding(?8), do: [1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1]
  def encoding(?9), do: [1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1]
  def encoding(?A), do: [1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1]
  def encoding(?B), do: [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1]
  def encoding(?C), do: [1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]
  def encoding(?D), do: [1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1]
  def encoding(?E), do: [1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1]
  def encoding(?F), do: [1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1]
  def encoding(?G), do: [1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1]
  def encoding(?H), do: [1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1]
  def encoding(?I), do: [1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1]
  def encoding(?J), do: [1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1]
  def encoding(?K), do: [1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1]
  def encoding(?L), do: [1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1]
  def encoding(?M), do: [1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1]
  def encoding(?N), do: [1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1]
  def encoding(?O), do: [1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1]
  def encoding(?P), do: [1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1]
  def encoding(?Q), do: [1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1]
  def encoding(?R), do: [1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1]
  def encoding(?S), do: [1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1]
  def encoding(?T), do: [1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1]
  def encoding(?U), do: [1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1]
  def encoding(?V), do: [1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1]
  def encoding(?W), do: [1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1]
  def encoding(?X), do: [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1]
  def encoding(?Y), do: [1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1]
  def encoding(?Z), do: [1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1]
  def encoding(?-), do: [1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1]
  def encoding(?.), do: [1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1]
  def encoding(?\s), do: [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1]
  def encoding(?$), do: [1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1]
  def encoding(?/), do: [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1]
  def encoding(?+), do: [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1]
  def encoding(?%), do: [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1]
  def encoding(invalid), do: {:error, "Invalid character found #{IO.chardata_to_string([invalid])}"}

  def start_symbol, do: [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1]
  def stop_symbol, do: start_symbol

  def encoding_index(?0), do: 0
  def encoding_index(?1), do: 1
  def encoding_index(?2), do: 2
  def encoding_index(?3), do: 3
  def encoding_index(?4), do: 4
  def encoding_index(?5), do: 5
  def encoding_index(?6), do: 6
  def encoding_index(?7), do: 7
  def encoding_index(?8), do: 8
  def encoding_index(?9), do: 9
  def encoding_index(?A), do: 10
  def encoding_index(?B), do: 11
  def encoding_index(?C), do: 12
  def encoding_index(?D), do: 13
  def encoding_index(?E), do: 14
  def encoding_index(?F), do: 15
  def encoding_index(?G), do: 16
  def encoding_index(?H), do: 17
  def encoding_index(?I), do: 18
  def encoding_index(?J), do: 19
  def encoding_index(?K), do: 20
  def encoding_index(?L), do: 21
  def encoding_index(?M), do: 22
  def encoding_index(?N), do: 23
  def encoding_index(?O), do: 24
  def encoding_index(?P), do: 25
  def encoding_index(?Q), do: 26
  def encoding_index(?R), do: 27
  def encoding_index(?S), do: 28
  def encoding_index(?T), do: 29
  def encoding_index(?U), do: 30
  def encoding_index(?V), do: 31
  def encoding_index(?W), do: 32
  def encoding_index(?X), do: 33
  def encoding_index(?Y), do: 34
  def encoding_index(?Z), do: 35
  def encoding_index(?-), do: 36
  def encoding_index(?.), do: 37
  def encoding_index(?\s), do: 38
  def encoding_index(?$), do: 39
  def encoding_index(?/), do: 40
  def encoding_index(?+), do: 41
  def encoding_index(?%), do: 42
  def encoding_index(invalid), do: {:error, "Invalid character found #{IO.chardata_to_string([invalid])}"}

  def index_to_char(0), do: ?0
  def index_to_char(1), do: ?1
  def index_to_char(2), do: ?2
  def index_to_char(3), do: ?3
  def index_to_char(4), do: ?4
  def index_to_char(5), do: ?5
  def index_to_char(6), do: ?6
  def index_to_char(7), do: ?7
  def index_to_char(8), do: ?8
  def index_to_char(9), do: ?9
  def index_to_char(10), do: ?A
  def index_to_char(11), do: ?B
  def index_to_char(12), do: ?C
  def index_to_char(13), do: ?D
  def index_to_char(14), do: ?E
  def index_to_char(15), do: ?F
  def index_to_char(16), do: ?G
  def index_to_char(17), do: ?H
  def index_to_char(18), do: ?I
  def index_to_char(19), do: ?J
  def index_to_char(20), do: ?K
  def index_to_char(21), do: ?L
  def index_to_char(22), do: ?M
  def index_to_char(23), do: ?N
  def index_to_char(24), do: ?O
  def index_to_char(25), do: ?P
  def index_to_char(26), do: ?Q
  def index_to_char(27), do: ?R
  def index_to_char(28), do: ?S
  def index_to_char(29), do: ?T
  def index_to_char(30), do: ?U
  def index_to_char(31), do: ?V
  def index_to_char(32), do: ?W
  def index_to_char(33), do: ?X
  def index_to_char(34), do: ?Y
  def index_to_char(35), do: ?Z
  def index_to_char(36), do: ?-
  def index_to_char(37), do: ?.
  def index_to_char(38), do: ?\s
  def index_to_char(39), do: ?$
  def index_to_char(40), do: ?/
  def index_to_char(41), do: ?+
  def index_to_char(42), do: ?%
end
