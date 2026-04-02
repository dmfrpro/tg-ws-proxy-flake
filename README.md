# Telegram WebSocket Proxy as a NixOS / Home-Manager module

This flake is a Nix wrapper around
https://github.com/Flowseal/tg-ws-proxy

## Installation as NixOS module

1. Add to flake.nix:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  tg-ws-proxy-flake.url = "github:dmfrpro/tg-ws-proxy-flake";
};
```

2. Add to your module imports:

```nix
outputs = { self, nixpkgs, tg-ws-proxy-flake, ... }: {
  nixosConfigurations.host = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      tg-ws-proxy-flake.nixosModules.tg-ws-proxy
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
outputs = { self, nixpkgs, home-manager, tg-ws-proxy-flake, ... }:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in {
  homeConfigurations."user@host" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      tg-ws-proxy-flake.nixosModules.tg-ws-proxy
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

## All options

| Option       | Type             | Default                                     | Description                                                                        |
|--------------|------------------|---------------------------------------------|------------------------------------------------------------------------------------|
| `enable`     | bool             | `false`                                     | Enable the proxy service.                                                          |
| `port`       | int              | `1443`                                      | Port the proxy listens on.                                                         |
| `host`       | string           | `"127.0.0.1"`                               | Host address to bind to.                                                           |
| `secret`     | null or string   | `null`                                      | 32 hex chars for client auth. If null, a random secret is generated each start.    |
| `dcIps`      | list of string   | `["2:149.154.167.220" "4:149.154.167.220"]` | Target DC IPs in `dc_id:ip_address` format.                                        |
| `bufKb`      | int              | `256`                                       | Buffer size in KB.                                                                 |
| `poolSize`   | int              | `4`                                         | Number of preallocated connections per DC.                                         |
| `logFile`    | null or path     | `null`                                      | Path to log file. If null, logs go to journal/stdout.                              |
| `logMaxMb`   | int              | `5`                                         | Max log file size in MB before rotation.                                           |
| `logBackups` | int              | `0`                                         | Number of log backups to keep.                                                     |
| `verbose`    | bool             | `false`                                     | Enable DEBUG logging.                                                              |
| `extraArgs`  | list of string   | `[]`                                        | Additional command line arguments.                                                 |
