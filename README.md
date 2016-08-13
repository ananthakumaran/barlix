# Barlix

![BARLIX](/media/logo.png?raw=true "BARLIX")

Barcode generator for Elixir

## Installation

```elixir
def deps do
  [{:barlix, "~> 0.1.0"}]
end

def application do
  [applications: [:barlix]]
end
```

## Example

```elixir
Barlix.Code39.encode!("BARLIX") |> Barlix.PNG.print(file: "/tmp/barcode.png")
```
