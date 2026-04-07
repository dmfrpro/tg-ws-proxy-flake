{
  description = "Local MTProto proxy for Telegram using WebSocket connections";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    let
      forAllSystems =
        f:
        inputs.nixpkgs.lib.genAttrs [
          "aarch64-linux"
          "x86_64-linux"
        ] (system: f (import inputs.nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          tg-ws-proxy = pkgs.callPackage ./packages/tg-ws-proxy.nix { };
        in
        {
          inherit tg-ws-proxy;
          default = tg-ws-proxy;
        }
      );

      nixosModules.tg-ws-proxy = import ./modules/nixos/default.nix;
      homeModules.tg-ws-proxy = import ./modules/home/default.nix;
    };
}
