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
  nu_version = "0.100.0";

  src = fetchFromGitHub {
    owner = "devyn";
    repo = "nu_plugin_dbus";
    rev = version;
    sha256 = "sha256-w+0H0A+wQa4BUzKx9G2isn29IicoZsLlWCDnC3YSzek=";
  };

  cargoHash = "sha256-NuWwPfAo3qYer4eUNDQ+VR9R+uLp5WAT2mhnr/zayEI=";

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
