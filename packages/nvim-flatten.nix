{
  vimUtils,
  fetchFromGitHub,
  ...
}:
vimUtils.buildVimPlugin {
  pname = "flatten-nvim";
  version = "2025-05-27";
  src = fetchFromGitHub {
    owner = "willothy";
    repo = "flatten.nvim";
    rev = "72527798e75b5e34757491947c2cb853ce21dc0e";
    sha256 = "sha256-NaOgzTVqOpQnEIOIMlHCupZUDYnLUic9zITKFxcOg3A=";
  };
  meta.homepage = "https://github.com/willothy/flatten.nvim";
}
