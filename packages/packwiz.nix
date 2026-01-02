{
  packwiz,
  fetchFromGitHub,
  ...
}:
packwiz.overrideAttrs (prev: next: {
  version = "0-unstable-2025-11-24";

  src = fetchFromGitHub {
    owner = "packwiz";
    repo = "packwiz";
    rev = "52b123018f9e19b49703f76e78ad415642acf5c5";
    sha256 = "sha256-EVs2PngdapCUSf6J946rpJWnEbM8TtlDQQS/Zg16Qfs=";
  };

  vendorHash = "sha256-P1SsvHTYKUoPve9m1rloBfMxUNcDKr/YYU4dr4vZbTE=";
})
