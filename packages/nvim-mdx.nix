{
  vimUtils,
  fetchFromGitHub,
  ...
}:
vimUtils.buildVimPlugin {
  pname = "mdx-nvim";
  version = "2026-04-15";
  src = fetchFromGitHub {
    owner = "davidmh";
    repo = "mdx.nvim";
    rev = "e165ee4acd2518f52078911d50a084bb433e9873";
    sha256 = "sha256-WChsEzRBFv8Z1LlhMol8eUKgmg20zIxtSQtvI78mC2g=";
  };
  meta.homepage = "https://github.com/davidmh/mdx.nvim";
}
