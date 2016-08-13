defmodule Barlix.UTFTest do
  use ExUnit.Case, async: true
  alias Barlix.Code39
  import Barlix.UTF
  import TestUtils
  doctest Barlix.UTF

  test "print" do
    assert_file_eq("utf/code39_barlix.txt", print(Code39.encode!("BARLIX")))
  end
end
