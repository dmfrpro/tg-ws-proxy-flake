{ pkgs, ... }:

let
  pyPkgs = pkgs.python314.pkgs;
in
pyPkgs.buildPythonPackage rec {
  pname = "tg-ws-proxy";
  version = "1.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "Flowseal";
    repo = "tg-ws-proxy";
    rev = "v${version}";
    hash = "sha256-c6Af+NzYuPhS4cewCnG5pz+93lLB6KzwEYEEikJ0vdA=";
  };

  format = "pyproject";

  build-system = with pyPkgs; [ setuptools ];

  dependencies = with pyPkgs; [
    aiohttp
    aiohttp-socks
    cryptography
    appdirs
    hatchling
    customtkinter
    pillow
    psutil
    pystray
    pyperclip
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'pyperclip==1.9.0' 'pyperclip>=1.9.0' \
      --replace-fail 'psutil==7.0.0;' 'psutil>=7.0.0;'
  '';

  doCheck = false;

  meta = {
    description = "Local MTProto proxy for Telegram using WebSocket connections";
    homepage = "https://github.com/Flowseal/tg-ws-proxy";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
  };
}
