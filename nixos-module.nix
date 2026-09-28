{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.pyndns;
in
{
  options.services.pyndns = {
    enable = mkEnableOption "PynDNS";

    package = mkOption {
      type = types.package;
      default = pkgs.pyndns;
      defaultText = lib.literalExpression "pkgs.pyndns";
      description = "The PynDNS package to use.";
    };

    basicSecretFile = mkOption {
      type = types.path;
      description = "Path to a file containing the DynDNS Basic Auth password.";
      example = "/run/secrets/pyndns-password";
    };

    apiKeyFile = mkOption {
      type = types.path;
      description = "Path to a file containing the PowerDNS API key.";
      example = "/run/secrets/pyndns-api-key";
    };

    username = mkOption {
      type = types.str;
      default = "fritz";
      description = "Username authorized to submit DynDNS updates.";
    };

    dynamicZone = mkOption {
      type = types.str;
      default = "dyn.athmer.org";
      description = "DNS zone whose AAAA records PynDNS updates.";
    };

    pdnsServerUrl = mkOption {
      type = types.str;
      default = "http://localhost:8081";
      description = "URL of the PowerDNS API server.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pyndns = {
      description = "PynDNS Dynamic DNS updater";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pyndns";
        LoadCredential = [
          "basic-secret:${cfg.basicSecretFile}"
          "api-key:${cfg.apiKeyFile}"
        ];
        Restart = "on-failure";
        RestartSec = "10s";

        # Run as an ephemeral, systemd-managed user/group instead of a static one;
        # DynamicUser also implies NoNewPrivileges, ProtectSystem=strict,
        # ProtectHome=read-only, PrivateTmp and RemoveIPC.
        DynamicUser = true;

        # Security hardening
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        PrivateDevices = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      environment = {
        BASIC_USERNAME = cfg.username;
        BASIC_SECRET_FILE = "%d/basic-secret";
        API_KEY_FILE = "%d/api-key";
        DYNAMIC_ZONE = cfg.dynamicZone;
        PDNS_SERVER_URL = cfg.pdnsServerUrl;
      };
    };
  };
}
