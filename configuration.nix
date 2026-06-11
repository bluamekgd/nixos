{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.extraEntries = "
    menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
      fwsetup
    }
  ";

  # MakeMKV fix
  boot.kernelModules = ["sg"];

  # Intel iGPU
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime

    # Holy shit this igpu is old :sob:
    mesa
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Tailscale (WireGuard for idiots)
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Firewall
  networking.firewall = {
    trustedInterfaces = [config.services.tailscale.interfaceName];
    allowedUDPPorts = [config.services.tailscale.port];
    checkReversePath = "loose";
  };

  # Locale / time
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # User and shell
  users.users.bartek = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
    shell = pkgs.zsh;
    initialPassword = "changeme";
  };

  # Gnome keyring cuz sway nixos guide says so
  services.gnome.gnome-keyring.enable = true;

  # XDG Portal (like the game? (i choked a sub-20 speedrun so bad bro))
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  # zsh
  programs.zsh.enable = true;

  # Nix experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    neovim
    alejandra
    nil
    pciutils
    usbutils
    brightnessctl
    playerctl
    libxcursor
    xwayland
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.inconsolata
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.noto

    inter
    source-sans
    source-serif
    source-code-pro
    corefonts
    vista-fonts
    cantarell-fonts
    freefont_ttf
    ubuntu-classic
    dejavu_fonts
    liberation_ttf

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # SwayWM
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      swaybg
      waybar
      fuzzel
      wl-clipboard
      grim
      slurp
      mako
    ];
  };

  # Ly DM
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Animation
      animation = "dur_file";
      dur_file_path = "/etc/nixos/resources/ly.dur";
      dur_x_offset = 0;
      dur_y_offset = 0;
      animation_timeout_sec = 0;

      # Clock / big clock
      bigclock = "en";
      bigclock_12hr = false;
      bigclock_seconds = false;

      # Brightness keys
      brightness_down_cmd = "${pkgs.brightnessctl}/bin/brightnessctl -q -n s 10%-";
      brightness_down_key = "F5";
      brightness_up_cmd = "${pkgs.brightnessctl}/bin/brightnessctl -q -n s +10%";
      brightness_up_key = "F6";

      # Appearance
      bg = "0x00000000";
      fg = "0x00FFFFFF";
      border_fg = "0x00FFFFFF";
      error_bg = "0x00000000";
      error_fg = "0x01FF0000";
      blank_box = true;
      hide_borders = false;
      hide_key_hints = false;
      hide_keyboard_locks = true;
      hide_version_string = true;
      text_in_center = false;
      full_color = true;
      edge_margin = 0;

      # Input
      input_len = 34;
      default_input = "password";
      asterisk = "*";
      clear_password = true;
      allow_empty_password = false;

      # Auth / session
      auth_fails = 10;
      save = true;
      service_name = "ly";
      numlock = true;

      # Battery
      battery_id = "BAT1";

      # Power keys
      shutdown_cmd = "/run/current-system/sw/bin/systemctl poweroff";
      shutdown_key = "F1";
      restart_cmd = "/run/current-system/sw/bin/systemctl reboot";
      restart_key = "F2";
      sleep_key = "F3";
      sleep_cmd = "/run/current-system/sw/bin/systemctl suspend";
      hibernate_key = "F4";
      hibernate_cmd = "/run/current-system/sw/bin/systemctl hibernate";

      # Margins
      margin_box_h = 2;
      margin_box_v = 1;

      # Misc
      lang = "en";
      min_refresh_delta = 5;
      session_log = ".local/state/ly-session.log";
    };
  };

  # Wayland env vars
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Laptop power management
  services.tlp.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Touchpad
  services.libinput.enable = true;

  # SSH
  services.openssh.enable = true;

  # Samba client
  services.gvfs.enable = true;

  # I did read the comment
  system.stateVersion = "24.11";
}
