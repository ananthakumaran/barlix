# Barlix

![BARLIX](./assets/logo.png "BARLIX")

[![.github/workflows/ci.yml](https://github.com/ananthakumaran/barlix/actions/workflows/ci.yml/badge.svg)](https://github.com/ananthakumaran/barlix/actions/workflows/ci.yml)
[![Module Version](https://img.shields.io/hexpm/v/barlix.svg)](https://hex.pm/packages/barlix)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/barlix/)
[![Total Download](https://img.shields.io/hexpm/dt/barlix.svg)](https://hex.pm/packages/barlix)
[![License](https://img.shields.io/hexpm/l/barlix.svg)](https://github.com/ananthakumaran/barlix/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/ananthakumaran/barlix.svg)](https://github.com/ananthakumaran/barlix/commits/master)


Barcode generator for Elixir.

## Installation

The package can be installed by adding `:barlix` to your list of dependencies in
`deps/0` function of `mix.exs` file:

```elixir
{:barlix, "~> 0.6"}
```

## Example

```elixir
Barlix.Code39.encode!("BARLIX") |> Barlix.PNG.print(file: "/tmp/barcode.png")
```

## Copyright and License

Copyright (c) 2016 Anantha Kumaran

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
