{
  lib,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "pyndns";
  version = "0.1.0";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ pkgs.pkg-config ];

  buildInputs = [ pkgs.openssl ];

  src = ./.;

  meta = with lib; {
    description = "Dynamic DNS updater for PowerDNS";
    homepage = "https://github.com/elmarx/pyndns";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "pyndns";
  };
}
