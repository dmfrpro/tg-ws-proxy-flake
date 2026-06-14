{ pkgs, lib, ... }:

let
  pyPkgs = pkgs.python314.pkgs;
in
pyPkgs.buildPythonPackage (finalAttrs: {
  pname = "tg-ws-proxy";
  version = "1.7.2";

  src = pkgs.fetchFromGitHub {
    owner = "Flowseal";
    repo = "tg-ws-proxy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WYOkwWRrEvP17Fgpu2tUt4vH0gLJKGYvOKSfW3dGV2Y=";
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
      --replace-fail 'psutil==7.0.0;' 'psutil>=7.0.0;' \
      --replace-fail 'cryptography==46.0.5' 'cryptography>=46.0.5' \
      --replace-fail 'Pillow==12.1.1;' 'Pillow>=12.1.1;'
  '';

  doCheck = false;

  meta = {
    description = "Telegram Desktop WebSocket Bridge Proxy";
    homepage = "https://github.com/Flowseal/tg-ws-proxy";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
