{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.tg-ws-proxy;
  pkg = pkgs.callPackage ../../packages/tg-ws-proxy.nix { };
in
{
  options.services.tg-ws-proxy = {
    enable = lib.mkEnableOption "TG WS Proxy (MTProto proxy for Telegram)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 1443;
      description = "Port the proxy listens on.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address to bind to.";
    };

    secret = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        32 hex chars secret for client authorization.
        If null, the program generates a random one on each start.
      '';
    };

    dcIps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "2:149.154.167.220"
        "4:149.154.167.220"
      ];
      description = ''
        Target IPs for DCs in format 'dc_id:ip_address'.
        Can be specified multiple times.
      '';
      example = [
        "2:149.154.167.220"
        "4:149.154.167.220"
      ];
    };

    bufKb = lib.mkOption {
      type = lib.types.int;
      default = 256;
      description = "Buffer size in KB.";
    };

    poolSize = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Number of preallocated connections per DC.";
    };

    logFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to log file. If null, logs go to journal/stdout.";
    };

    logMaxMb = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Maximum log file size in MB before rotation.";
    };

    logBackups = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Number of log backups to keep after rotation.";
    };

    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable verbose (DEBUG) logging.";
    };

    noCfProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable attempt to proxy through Cloudflare.";
    };

    cfproxyDomain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Custom domain to use for Cloudflare proxying.";
      example = "proxy.example.com";
    };

    cfproxyPriority = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Try proxying through Cloudflare before direct TCP connection.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command line arguments to pass to tg-ws-proxy.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.tg-ws-proxy = {
      Unit = {
        Description = "Local MTProto proxy for Telegram";
        After = [ "network.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [
            "${pkg}/bin/tg-ws-proxy"
            "--port"
            (toString cfg.port)
            "--host"
            cfg.host
            "--buf-kb"
            (toString cfg.bufKb)
            "--pool-size"
            (toString cfg.poolSize)
          ]
          ++ lib.optionals (cfg.secret != null) [
            "--secret"
            cfg.secret
          ]
          ++ lib.concatMap (dc: [
            "--dc-ip"
            dc
          ]) cfg.dcIps
          ++ lib.optionals (cfg.logFile != null) [
            "--log-file"
            cfg.logFile
          ]
          ++ [
            "--log-max-mb"
            (toString cfg.logMaxMb)
          ]
          ++ [
            "--log-backups"
            (toString cfg.logBackups)
          ]
          ++ lib.optionals cfg.verbose [ "--verbose" ]
          ++ lib.optionals cfg.noCfProxy [ "--no-cfproxy" ]
          ++ lib.optionals (cfg.cfproxyDomain != null) [
            "--cfproxy-domain"
            cfg.cfproxyDomain
          ]
          ++ [
            "--cfproxy-priority"
            (if cfg.cfproxyPriority then "true" else "false")
          ]
          ++ cfg.extraArgs
        );
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
        DevicePolicy = "closed";
        KeyringMode = "private";
        PrivateTmp = true;
        PrivateMounts = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
