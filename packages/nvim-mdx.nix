{
  vimUtils,
  fetchFromGitHub,
  ...
}:
vimUtils.buildVimPlugin {
  pname = "mdx-nvim";
  version = "2025-01-04";
  src = fetchFromGitHub {
    owner = "davidmh";
    repo = "mdx.nvim";
    rev = "464a74be368dce212cff02f6305845dc7f209ab3";
    sha256 = "sha256-jpMcrWx/Rg9sMfkQFXnIM8VB5qRuSB/70wuSh6Y5uFk=";
  };
  meta.homepage = "https://github.com/davidmh/mdx.nvim";
}
