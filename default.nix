{ lib, rustPlatform, pkgs }:

rustPlatform.buildRustPackage rec {
  pname = "dyndns";
  version = "0.1.0";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = [ pkgs.openssl ];

  src = ./.;
}
