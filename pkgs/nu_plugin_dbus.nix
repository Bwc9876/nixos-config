{
  rustPlatform,
  dbus,
  nushell,
  pkg-config,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "nu_plugin_dbus";
  version =
    if nushell.version == nu_version
    then "0.13.0"
    else abort "Nushell Version mismatch\nPlugin: ${nu_version}\tnixpkgs: ${nushell.version}";
  nu_version = "0.101.0";

  src = fetchFromGitHub {
    owner = "LordMZTE";
    repo = "nu_plugin_dbus";
    rev = "baa52026c3e8e4c6296d5545fd26237287436dad";
    sha256 = "sha256-Ga+1zFwS/v+3iKVEz7TFmJjyBW/gq6leHeyH2vjawto=";
  };

  cargoHash = "sha256-5GE8fylq7AB4VWJMvBNLw4a9ksNmn1iHk7wx9wOG6yE=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  meta = with lib; {
    description = "A nushell plugin for interacting with dbus";
    license = licenses.mit;
    homepage = "https://github.com/devyn/nu_plugin_dbus";
  };
}
