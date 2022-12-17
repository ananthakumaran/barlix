{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = [ (pkgs.beam.packagesWith pkgs.erlangR25).elixir_1_14 ];
}

