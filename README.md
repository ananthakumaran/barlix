# Barlix

![BARLIX](https://raw.githubusercontent.com/ananthakumaran/barlix/master/media/logo.png "BARLIX")

[![Build Status](https://secure.travis-ci.org/ananthakumaran/barlix.svg)](http://travis-ci.org/ananthakumaran/barlix)
[![Hex.pm](https://img.shields.io/hexpm/v/barlix.svg)](https://hex.pm/packages/barlix)

Barcode generator for Elixir

## Installation

```elixir
def deps do
  [{:barlix, "~> x.x.x"}]
end

```

## Example

```elixir
Barlix.Code39.encode!("BARLIX")
|> Barlix.PNG.print(file: "/tmp/barcode.png")
```

see [documentation](https://hexdocs.pm/barlix/) for more information.
