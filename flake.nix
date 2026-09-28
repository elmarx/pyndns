{
  description = "PynDNS, a Dynamic DNS updater for PowerDNS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      rust-overlay,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, pkgs, ... }:
        let
          rustPkgs = import nixpkgs {
            inherit system;
            overlays = [ (import rust-overlay) ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs =
              with rustPkgs;
              [
                (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })

                nixfmt

                opentofu
              ];
          };

          packages.default = pkgs.callPackage ./default.nix { };
        };

      flake = {
        overlays.default = final: prev: { pyndns = self.packages.${final.system}.default; };

        nixosModules.default = {
          imports = [ ./nixos-module.nix ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
      };
    };
}
