defmodule Barlix.UTFTest do
  use ExUnit.Case, async: true
  import Barlix.UTF
  import TestUtils
  doctest Barlix.UTF

  test "print" do
    assert_file_eq("utf/code39_barlix.txt", print(Barlix.Code39.encode!("BARLIX")))
    assert_file_eq("utf/code93_barlix.txt", print(Barlix.Code93.encode!("BARLIX")))
  end
end
