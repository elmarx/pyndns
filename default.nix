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

  nativeBuildInputs = [
    pkgs.cacert
  ];

  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

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
