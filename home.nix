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
    firefox
    jellyfin-desktop
    bat
    makemkv
    handbrake
    localsend
    vlc
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
      name = "Gruvbox-Dark-B";
      package = pkgs.gruvbox-gtk-theme;
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
  xdg.configFile."gtk-4.0/assets".source = "${pkgs.gruvbox-gtk-theme}/share/themes/Gruvbox-Dark-B/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source = "${pkgs.gruvbox-gtk-theme}/share/themes/Gruvbox-Dark-B/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source = "${pkgs.gruvbox-gtk-theme}/share/themes/Gruvbox-Dark-B/gtk-4.0/gtk-dark.css";

  # Cursor
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };

  # Waybar
  home.file.".config/waybar" = {
    source = ./resources/waybar;
    recursive = true;
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

  # SwayWM
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = {
      # Window borders and gaps
      gaps = {
        inner = 4;
        outer = 10;
      };
      window = {
        border = 6;
        titlebar = false;
      };
      floating = {
        border = 6;
        titlebar = false;
      };
      colors = {
        focused = {
          border = "#ebdbb2";
          background = "#ebdbb2";
          text = "#1e1e2e";
          indicator = "#ebdbb2";
          childBorder = "#ebdbb2";
        };
        unfocused = {
          border = "#1d2021";
          background = "#1d2021";
          text = "#1e1e2e";
          indicator = "#1d2021";
          childBorder = "#1d2021";
        };
      };

      # XCursor
      seat = {
        "*" = {
          xcursor_theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
        };
      };

      # Removing "The Devil's Absolute Nightmare"
      input = {
        "*" = {
          accel_profile = "flat";
          # "The Devil's Absolute Nightmare" Removed, Yay!!!!!!

          # Sensitivity
          pointer_accel = "0";
        };
      };

      # Preferences
      modifier = "Mod4";
      terminal = "kitty --title kitty";
      menu = "fuzzel";
      defaultWorkspace = "1";

      # Waybar and background
      startup = [
        {command = "waybar";}
        {command = "swaybg -o eDP-1 -i /etc/nixos/resources/swaybg.png -m fill";}
        # The best solution to a problem is usually the easiest. -Ellen McLain (GLaDOS), 2011
        {command = "swaymsg workspace number 1";}
      ];

      # I have waybar bro
      bars = [];

      keybindings = let
        # Read from preferences
        mod = config.wayland.windowManager.sway.config.modifier;
        terminal = config.wayland.windowManager.sway.config.terminal;
        menu = config.wayland.windowManager.sway.config.menu;
        fileManager = "nautilus";
      in {
        # ------------------ Keybinds ------------------

        # ------ Apps ------

        "${mod}+Return" = "exec ${terminal}";
        "${mod}+Space" = "exec ${menu}";
        "${mod}+e" = "exec ${fileManager}";
        "${mod}+q" = "kill";

        # ------ Login ------

        "${mod}+Shift+L" = "exec swaymsg exit";
        "${mod}+L" = "exec swaylock";

        # ------------ Window management ------------

        # ------ Movement ------

        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up" = "focus up";
        "${mod}+Down" = "focus down";

        # ------ Workspaces ------

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+S" = "scratchpad show";
        "${mod}+Shift+S" = "move scratchpad";
      };
    };
  };

  # I did read the comment
  home.stateVersion = "24.11";
}
