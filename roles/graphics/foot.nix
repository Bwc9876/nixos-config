{...}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        title = "Terminal (Foot)";
        term = "xterm-256color";
        font = "monospace:size=18";
      };
      bell = {
        visual = true;
      };
      cursor = {
        style = "beam";
        blink = true;
      };
    };
  };
}
