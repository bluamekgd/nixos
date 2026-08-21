{
  config,
  pkgs,
  ...
}: {
  home.username = "bartek";
  home.homeDirectory = "/home/bartek";

  home.packages = with pkgs; [
    kitty
    samba
    nautilus
    floorp-bin
    jellyfin-desktop
    bat
    makemkv
    handbrake
    localsend
    vlc
    discord

    # Larping Tools
    fastfetch
  ];

  # GTK Prefer Dark
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Main config for GTK2/3/4 assets
  gtk = {
    enable = true;

    # Old NixOS thing
    gtk4.theme = config.gtk.theme;

    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-dark-gtk;
    };

    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };

    # Fallback :))))))))))
    gtk2.extraConfig = "
      gtk-application-prefer-dark-theme = 1
    ";
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Libadwaita hell
  xdg.configFile."gtk-4.0/assets".source = "${pkgs.gruvbox-dark-gtk}/share/themes/Gruvbox-Dark/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source = "${pkgs.gruvbox-dark-gtk}/share/themes/Gruvbox-Dark/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source = "${pkgs.gruvbox-dark-gtk}/share/themes/Gruvbox-Dark/gtk-4.0/gtk-dark.css";

  # Cursor
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };

  # Git pre-commit Nix syntax check
  home.file.".git/hooks/pre-commit" = {
    executable = true;
    text = ''
    #!/usr/bin/env bash
    set -e
    if find . -name "*.nix" -print -quit | grep -q .; then
      echo "running nix syntax check"
      find . -name "*.nix" -exec ${pkgs.nix}/bin/nix-instantiate --parse {} + > /dev/null
      echo "nix syntax ok"
    fi'';
  };

  # Niri (todo: done ig)
  home.file.".config/niri/config.kdl" = {
    source = ./resources/niri/config.kdl;
    recursive = true;
  };

  # awww
  home.file.".awww.png" = {
    source = ./resources/awww.png;
  };

  # Terminal
  home.file.".config/kitty" = {
    source = ./resources/kitty;
    recursive = true;
  };
  programs.starship.enable = true;
  home.file.".config/starship.toml" = {
    source = ./resources/starship.toml;
  };
  home.file.".zshrc" = {
    source = ./resources/.zshrc;
  };

  # Fuzzel
  home.file.".config/fuzzel/fuzzel.ini" = {
    source = ./resources/fuzzel.ini;
  };

  # I did read the comment
  home.stateVersion = "24.11";
}
