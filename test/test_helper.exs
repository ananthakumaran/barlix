Application.start(:tempfile)
ExUnit.start()

defmodule TestUtils do
  require Logger
  import ExUnit.Assertions

  def s_to_l(string) do
    list = Enum.map(String.codepoints(string), fn (x) ->
      case x do
        "1" -> 1
        "0" -> 0
      end
    end)
    {:D1, list}
  end

  def assert_file_eq(path, contents) do
    full_path = Path.join([__DIR__, "fixtures", path])
    if File.exists?(full_path) do
      actual = File.read!(full_path)
      assert actual == IO.iodata_to_binary(contents)
    else
      Logger.warn "File #{path} doesn't exist, creating new one"
      File.mkdir_p!(Path.dirname(full_path))
      File.write!(full_path, contents)
    end
  end
end
