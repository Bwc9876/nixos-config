{...}: let
  fontSize = "18";
in {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        title = "Terminal (Foot)";
        term = "xterm-256color";
        font = "monospace:size=${fontSize}";
      };
      bell = {
        visual = true;
      };
      cursor = {
        style = "beam";
        blink = true;
      };
      colors = {
        alpha = "0.8";
        background = "101013";
        foreground = "fcfcfc";
        regular0 = "444a4c";
        bright0 = "565f61";
        dim0 = "303536";
        regular1 = "ed254e";
        bright1 = "f04265";
        dim1 = "d91239";
        regular2 = "71f79f";
        bright2 = "9af9bb";
        dim2 = "4df587";
        regular3 = "fadd00";
        bright3 = "ffe629";
        dim3 = "d1b900";
        regular4 = "0072ff";
        bright4 = "2989ff";
        dim4 = "0060d6";
        regular5 = "d400dc";
        bright5 = "f70aff";
        dim5 = "ad00b3";
        regular6 = "00c1e4";
        bright6 = "0fdbff";
        dim6 = "00a0bd";
        regular7 = "fcfcfc";
        bright7 = "ffffff";
        dim7 = "e8e8e8";
      };
    };
  };
}
