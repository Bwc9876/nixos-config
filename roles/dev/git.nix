{pkgs, ...}: {
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      commit.gpgSign = true;
      user = {
        email = "bwc9876@gmail.com";
        name = "Ben C";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
      };
      advice = {
        addIgnoredFile = false;
      };
      gpg.format = "ssh";
    };
  };
}
