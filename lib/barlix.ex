defmodule Barlix do
  defmodule Error do
    defexception [:message]
  end

  @type code :: [0|1]
end
