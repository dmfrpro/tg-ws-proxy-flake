{
  description = "Local MTProto proxy for Telegram using WebSocket connections";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem = { pkgs, ... }: {
        packages.tg-ws-proxy = pkgs.callPackage ./packages/tg-ws-proxy.nix { };
        packages.default = pkgs.lib.mkForce (pkgs.callPackage ./packages/tg-ws-proxy.nix { });
      };

      flake = {
        nixosModules.tg-ws-proxy = import ./modules/nixos/default.nix;
        homeModules.tg-ws-proxy = import ./modules/home/default.nix;
      };
    };
}
