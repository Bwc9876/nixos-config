{
  lib,
  stdenv,
  fetchFromGitHub,
  libxml2,
  curl,
  libseccomp,
  installShellFiles,
}:
stdenv.mkDerivation {
  pname = "rdrview";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "eafer";
    repo = "rdrview";
    rev = "0bf7b5abfa22c252761f594c3bd6228947c50155";
    sha256 = "sha256-UFHRsaLGa/jv/S+VXtXIMgLuQUPgqbRgD35bBrJyuZA=";
  };

  buildInputs = [
    libxml2
    curl
    libseccomp
  ];
  nativeBuildInputs = [installShellFiles];

  installPhase = ''
    runHook preInstall
    install -Dm755 rdrview -t $out/bin
    installManPage rdrview.1
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Command line tool to extract main content from a webpage";
    homepage = "https://github.com/eafer/rdrview";
    license = licenses.asl20;
    maintainers = with maintainers; [djanatyn];
    mainProgram = "rdrview";
  };
}
