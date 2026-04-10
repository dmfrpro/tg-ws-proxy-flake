# Telegram WebSocket Proxy as a NixOS / Home-Manager module

This flake is a Nix wrapper around
https://github.com/Flowseal/tg-ws-proxy

## Installation as NixOS module

1. Add to flake.nix:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  tg-ws-proxy.url = "github:dmfrpro/tg-ws-proxy-flake";
  tg-ws-proxy.inputs.nixpkgs.follows = "nixpkgs";
};
```

2. Add to your module imports:

```nix
outputs = { self, nixpkgs, tg-ws-proxy, ... }: {
  nixosConfigurations.host = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      tg-ws-proxy.nixosModules.tg-ws-proxy
    ];
  };
};
```

3. Enable the service:

```nix
{
  services.tg-ws-proxy.enable = true;
}
```

## Installation as Home-Manager module

1. Add to flake.nix:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  tg-ws-proxy-flake.url = "github:dmfrpro/tg-ws-proxy-flake-flake";
};
```

2. Add to your module imports:

```nix
outputs = { self, nixpkgs, home-manager, tg-ws-proxy, ... }:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in {
  homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      tg-ws-proxy.homeModules.tg-ws-proxy
    ];
  };
};
```

3. Enable the service:

```nix
{
  services.tg-ws-proxy.enable = true;
}
```

## Usage

You will need to either pin MTProto secret:

```nix
{
  services.tg-ws-proxy = {
    enable = true;
    secret = "3075abe65830f0325116bb0416cadf9f"; # openssl rand -hex 16
  };
}
```

And manually add proxy in Telegram one time.

Or extract the secret from systemd logs (service generates random secret on startup):

```bash
Apr 07 11:14:34 hostname systemd[1]: Started Local MTProto proxy for Telegram.
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO   ============================================================
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO     Telegram MTProto WS Bridge Proxy
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO     Listening on   127.0.0.1:1443
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO     Secret:        3075abe65830f0325116bb0416cadf9f
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO     Target DC IPs:
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO       DC2: 149.154.167.220
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO       DC4: 149.154.167.220
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO   ============================================================
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO     Connect link:
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO       tg://proxy?server=127.0.0.1&port=1443&secret=dd3075abe65830f0325116bb0416cadf9f
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO   ============================================================
Apr 07 11:14:34 hostname tg-ws-proxy[1636]: 11:14:34  INFO   WS pool warmup started for 2 DC(s)
```

And open Telegram via `xdg-open`:

```bash
xdg-open "tg://proxy?server=127.0.0.1&port=1443&secret=dd3075abe65830f0325116bb0416cadf9f"
```

## All options

| Option            | Type             | Default                                     | Description                                                                        |
|-------------------|------------------|---------------------------------------------|------------------------------------------------------------------------------------|
| `enable`          | bool             | `false`                                     | Enable the proxy service.                                                          |
| `port`            | int              | `1443`                                      | Port the proxy listens on.                                                         |
| `host`            | string           | `"127.0.0.1"`                               | Host address to bind to.                                                           |
| `secret`          | null or string   | `null`                                      | 32 hex chars for client auth. If null, a random secret is generated each start.    |
| `dcIps`           | list of string   | `["2:149.154.167.220" "4:149.154.167.220"]` | Target DC IPs in `dc_id:ip_address` format.                                        |
| `bufKb`           | int              | `256`                                       | Buffer size in KB.                                                                 |
| `poolSize`        | int              | `4`                                         | Number of preallocated connections per DC.                                         |
| `logFile`         | null or path     | `null`                                      | Path to log file. If null, logs go to journal/stdout.                              |
| `logMaxMb`        | int              | `5`                                         | Max log file size in MB before rotation.                                           |
| `logBackups`      | int              | `0`                                         | Number of log backups to keep.                                                     |
| `noCfProxy`       | bool             | `false`                                     | Disable attempt to proxy through Cloudflare.                                       |
| `cfproxyDomain`   | bool             | `null`                                      | Custom domain to use for Cloudflare proxying.                                      |
| `cfproxyPriority` | bool             | `true`                                      | Try proxying through Cloudflare before direct TCP connection.                      |
| `verbose`         | bool             | `false`                                     | Enable DEBUG logging.                                                              |
| `extraArgs`       | list of string   | `[]`                                        | Additional command line arguments.                                                 |
