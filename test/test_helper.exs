ExUnit.start()

defmodule TestUtils do
  require Logger
  import ExUnit.Assertions

  def s_to_l(string) do
    list =
      Enum.map(String.codepoints(string), fn x ->
        case x do
          "1" -> 1
          "0" -> 0
        end
      end)

    {:D1, list}
  end

  def l_to_s({:D1, list}) do
    Enum.map(list, &Integer.to_string/1) |> to_string
  end

  def assert_file_eq(path, contents) do
    full_path = Path.join([__DIR__, "fixtures", path])

    if File.exists?(full_path) do
      actual = File.read!(full_path)
      assert IO.iodata_to_binary(actual) == IO.iodata_to_binary(contents)
    else
      Logger.warning("File #{path} doesn't exist, creating new one")
      File.mkdir_p!(Path.dirname(full_path))
      File.write!(full_path, contents)
    end
  end
end
