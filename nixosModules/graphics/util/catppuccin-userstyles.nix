lib: importJson:
let
  updateVar = var: val: {
    path = [
      "usercssData"
      "vars"
      var
      "value"
    ];
    update = (old: val);
  };
  setVars =
    {
      lightFlavor,
      darkFlavor,
      accent,
    }:
    lib.updateManyAttrsByPath [
      (updateVar "lightFlavor" lightFlavor)
      (updateVar "darkFlavor" darkFlavor)
      (updateVar "accentColor" accent)
    ];
  # First element is the settings, pass that later
  cleanedJson = (builtins.tail importJson);
  stylusSettings = {
    dbInChromeStorage = true;
    settings = (builtins.head importJson).settings // {
      # Earlier injection of styles via XmlHttpRequest
      styleViaXhr = true;
    };
  };
  md5ToUuidThisIsVeryBad =
    md5:
    let
      first = builtins.substring 0 8 md5;
      second = builtins.substring 8 4 md5;
      third = builtins.substring 12 4 md5;
      fourth = builtins.substring 16 4 md5;
      fifth = builtins.substring 20 12 md5;
    in
    "${first}-${second}-${third}-${fourth}-${fifth}";
in
{
  lightFlavor ? "latte",
  darkFlavor ? "mocha",
  accent ? "mauve",
}:
let
  # I'm a stupid idiot there has to be a better way to do this
  setVars' = setVars { inherit lightFlavor darkFlavor accent; };
  mkStylePair = i: style: {
    name = "style-${builtins.toJSON i}";
    value = (setVars' style) // {
      id = i;
      # # Stylus code says Date.now() for rev, we'll just set it to 0?
      # _rev = 0;
      # # Please forgive me for what I'm about to do.
      # _id = md5ToUuidThisIsVeryBad style.originalDigest;
    };
  };
  generatedStyles = lib.imap mkStylePair cleanedJson;
in
stylusSettings // (builtins.listToAttrs generatedStyles)
