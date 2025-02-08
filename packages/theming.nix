{
  gtk3,
  runCommand,
  fetchFromGitHub,
}: let
  src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "Sweet";
    rev = "051ee62cf998c8c95bd0b391eb3996d09d94dbcd"; # Ambar-Blue: https://github.com/EliverLara/Sweet/commits/Ambar-Blue/
    hash = "sha256-laFBNuXUGw2wKregIyU4r/PMP/zLC3bATDl3eqvWy3o=";
  };
  icons-src = fetchFromGitHub {
    owner = "EliverLara";
    repo = "candy-icons";
    rev = "6f6eb3d7dbdb4fb9aab31ec5aebeb7155225f0ab"; # master: https://github.com/EliverLara/candy-icons/commits/master/
    hash = "sha256-VOUFs45n+5zQqk3pPsiQeL6aCWEUUje90PGt2ni7Bgg=";
  };
  cursor-src = ../res/cursors/Sweet-cursors.tar.xz;
  hypr-cursor-src = ../res/cursors/Sweet-cursors-hypr.tar.xz;
in
  runCommand "sweet-ambar-blue" {} ''

    # Candy Icons
    mkdir -p $out/share/icons/candy-icons
    cp -r ${icons-src}/* $out/share/icons/candy-icons
    chmod +w $out/share/icons/candy-icons/apps/scalable
    ln -s -T $out/share/icons/candy-icons/apps/scalable/firefox-developer.svg $out/share/icons/candy-icons/apps/scalable/firefox-devedition.svg
    ln -s -T $out/share/icons/candy-icons/apps/scalable/rss_indicator.svg $out/share/icons/candy-icons/apps/scalable/newsboat.svg
    ln -s -T $out/share/icons/candy-icons/apps/scalable/discord.svg $out/share/icons/candy-icons/apps/scalable/vesktop.svg
    ln -s -T $out/share/icons/candy-icons/apps/scalable/screengrab.svg $out/share/icons/candy-icons/apps/scalable/swappy.svg

    rm $out/share/icons/candy-icons/apps/scalable/vscodium.svg
    ln -s -T $out/share/icons/candy-icons/apps/scalable/code.svg $out/share/icons/candy-icons/apps/scalable/vscodium.svg

    # Cursor Theme
    tar -xf ${cursor-src} -C $out/share/icons
    tar -xf ${hypr-cursor-src} -C $out/share/icons

    # Kvantum
    mkdir -p $out/share/Kvantum
    cp -r ${src}/kde/kvantum/Sweet-Ambar-Blue $out/share/Kvantum

    # GTK Themes
    mkdir -p $out/share/themes/Sweet-Ambar-Blue
    cp -r ${src}/gtk-2.0 $out/share/themes/Sweet-Ambar-Blue
    cp -r ${src}/gtk-3.0 $out/share/themes/Sweet-Ambar-Blue
    cp -r ${src}/gtk-4.0 $out/share/themes/Sweet-Ambar-Blue
    cp -r ${src}/assets $out/share/themes/Sweet-Ambar-Blue
    cp -r ${src}/index.theme $out/share/themes/Sweet-Ambar-Blue

    ${gtk3}/bin/gtk-update-icon-cache -f -t $out/share/icons/candy-icons
    ${gtk3}/bin/gtk-update-icon-cache -f -t $out/share/icons/Sweet-cursors
  ''
