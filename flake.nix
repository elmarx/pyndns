{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            pkg-config
            openssl

            (rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; })
            cargo-outdated
            cargo-watch

            nixpkgs-fmt

            terraform
            ansible
          ] ++ lib.optionals (stdenv.isDarwin) [ darwin.apple_sdk.frameworks.Security ];

          # required for ansible
          LC_ALL = "C.UTF-8";
        };
      }
    );
}
