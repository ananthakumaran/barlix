defmodule Barlix do
  @moduledoc """
  Barlix aims to provide a flexible set of modules to generate and
  render barcodes. Currently it only supports a few symbologies. I
  hope to add more encoders and renderers in the future.

  ## Example

  ```
  Barlix.Code39.encode!("BARLIX")
  |> Barlix.PNG.print(file: "/tmp/barcode.png")
  ```

  ## Encoders

  * `Barlix.Code39`
  * `Barlix.Code93`
  * `Barlix.Code128`
  * `Barlix.ITF`

  ## Renderers

  * `Barlix.UTF`
  * `Barlix.PNG`
  * `Barlix.SVG`
  """

  defmodule Error do
    defexception [:message]
  end

  @type code :: {:D1, [0 | 1]}
end
