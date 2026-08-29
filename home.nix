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
    ./apps/firefox.nix
  ];

  home.packages = with pkgs; [
    kitty
    samba
    nautilus
    jellyfin-desktop
    bat
    makemkv
    handbrake
    localsend
    vlc
    discord
    gimp
    loupe

    # Nix Search TV
    (pkgs.writeShellApplication
    {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
	nix-search-tv
      ];
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    })

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
	community_palette = "Catppuccin Mocha Maroon";
      };
      wallpaper = {
        enabled = true;
	directory = "~/Pictures/Wallpapers";
	transition_on_startup = true;
	automation.enabled = true;
      };
      
      bar.default = {
        start = [ "launcher" "wallpaper" "workspaces" ];
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
      idle = {
        behavior_order = [ "lock" "lock-and-suspend" ];
	behavior = {
	  lock = {
            action = "lock";
	    enabled = true;
  	    timeout = 600.0;
	  };
	  lock-and-suspend = {
            action = "lock_and_suspend";
	    enabled = true;
	    timeout = 900.0;
	  };
	};
      };
      shell = {
        avatar_path = "/var/lib/AccountsService/icons/${config.home.username}";
        font_family = "JetBrainsMonoNL NFM";
	password_style = "random";
	show_location = false;
	greeter_sync = {
          auto_sync = true;
	  privilege_command = "pkexec";
	};
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
    source = ./resources/niri.kdl;
    recursive = true;
  };
  
  # Wallpapers
  home.file."Pictures/Wallpapers" = {
    source = ./resources/wallpapers;
    recursive = true;
  };

  # Terminal
  programs.kitty = {
    enable = true;

    settings = {
      # Colors
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      scrollbar_handle_color = "#9399b2";
      scrollbar_track_color = "#45475a";
      url_color = "#f5e0dc";
      active_border_color = "#b4befe";
      inactive_border_color = "#6c7086";
      bell_border_color = "#f9e2af";
      wayland_titlebar_color = "system";

      mark1_foreground = "#1e1e2e";
      mark1_background = "#b4befe";
      mark2_foreground = "#1e1e2e";
      mark2_background = "#cba6f7";
      mark3_foreground = "#1e1e2e";
      mark3_background = "#74c7ec";

      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      color7 = "#bac2de";
      color15 = "#a6adc8";

      # Config
      font_family = "JetBrainsMonoNL Nerd Font Mono";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      window_padding_width = "5 10";
      confirm_os_window_close = 0;
      background_opacity = 0.5;
      background_blur = 64;
      hide_window_decorations = true;
      tab_bar_style = "hidden";
    };
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
