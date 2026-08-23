{
  inputs,
  config,
  pkgs,
  ...
}: {
  home.username = "bartek";
  home.homeDirectory = "/home/bartek";

  imports = [
    inputs.noctalia.homeModules.default
  ];

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
    discord

    # Larping Tools
    fastfetch
    inputs.larpfetch.packages.${pkgs.stdenv.hostPlatform.system}.default
    cava
    cmatrix
    cbonsai
    btop
    pipes-rs
    tty-clock
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

  # Noctalia
  programs.noctalia = {
    enable = true;
    settings = {
      theme = {
        mode = "dark";
	source = "community";
	community_palette = "Catppuccin Mocha Mauve-Lavender";
      };
      wallpaper = {
        enabled = true;
	directory = "~/Pictures/Wallpapers";
	transition_on_startup = true;
	automation.enabled = true;
      };
      bar.default = {
        start = [ "launcher" "workspaces" ];
	end = [
          "tray"
	  "notifications"
	  "clipboard"
	  "network"
	  "bluetooth"
	  "volume"
	  "brightness"
	  "battery"
	  "control-center"
	];
      };
      control_center.calendar.show_events_card = false;
      desktop_widgets.enabled = false;
      location.auto_locate = true;
      lockscreen_widgets.enabled = false;
      shell = {
        font_family = "JetBrainsMonoNL NFM";
	password_style = "random";
	show_location = false;
	launcher = {
          categories = false;
	  compact = true;
	};
	panel.launcher_placement = "attached";
	screenshot = {
          directory = "~/Pictures/Screenshots";
	  show_cursor = true;
	};
	session.actions = [
          {
            action = "lock";
	    countdown_seconds = 0.0;
	    enabled = true;
	    shortcut = "1";
	    variant = "default";
	  }
	  {
            action = "logout";
	    countdown_seconds = 0.0;
	    enabled = true;
	    shortcut = "2";
	    variant = "default";
	  }
	  {
            action = "lock_and_suspend";
	    countdown_seconds = 0.0;
	    enabled = true;
	    label = "Sleep";
	    shortcut = "3";
	    variant = "default";
	  }
	  {
            action = "reboot";
	    countdown_seconds = 0.0;
	    enabled = true;
	    shortcut = "4";
	    variant = "destructive";
	  }
	  {
            action = "shutdown";
	    countdown_seconds = 0.0;
	    enabled = true;
	    shortcut = "5";
	    variant = "destructive";
	  }
	];
      };
    };
  };

  # Fastfetch
  home.file.".config/fastfetch/config.jsonc" = {
    source = ./resources/fastfetch.jsonc;
  };

  # Niri (todo: done ig)
  home.file.".config/niri/config.kdl" = {
    source = ./resources/niri/config.kdl;
    recursive = true;
  };
  
  # Wallpapers
  home.file."Pictures/Wallpapers" = {
    source = ./resources/wallpapers;
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

  # I did read the comment
  home.stateVersion = "24.11";
}
