{
  inputs,
  config,
  pkgs,
  ...
}: {


  imports = [
    ./hardware-configuration.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 2;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  boot.loader.grub.extraEntries = "
    menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
      fwsetup
    }
  ";

  # Maybe not

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

  # XDG Portal (like the game? (I DID A 10:00.7 IN OOB BRO I HATE THIS GAME))
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.niri.default = [ "gnome" "gtk" ];
  };

  # Polkit exception for Noctalia
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.noctalia.greeter.apply-appearance" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # zsh
  programs.zsh.enable = true;

  # Nix experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # System packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    
    # System
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

    # Wayland + Niri shit
    libxcursor
    xwayland
    wl-clipboard
    grim
    slurp
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  # Niri
  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  # Noctalia Greeter
  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "";

    settings = {
      appearance = {
        password_style = "random";
	hide_logo = true;
      };

      cursor = {
        theme = "Bibata-Modern-Classic";
	size = 22;
	path = "${pkgs.bibata-cursors}/share/icons";
      };

      session.default = "niri";
      keyboard.layout = "us";
    };
  };

  # Greeter avatar, served entirely outside $HOME — no ACLs on
  # /home/bartek needed, no tmpfiles hack, nothing for `greeter`
  # to traverse.
  system.activationScripts.greeterAvatar = ''
    mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
    install -m 0644 ${./resources/face.png} /var/lib/AccountsService/icons/bartek
    cat > /var/lib/AccountsService/users/bartek <<'EOF'
  [User]
  Icon=/var/lib/AccountsService/icons/bartek
  SystemAccount=false
  EOF
  '';

  # Wayland env vars
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # Laptop power management
  services.tuned.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Bluetooth (wow it does)
  hardware.bluetooth.enable = true;

  # Touchpad
  services.libinput.enable = true;

  # SSH
  services.openssh.enable = true;

  # Samba client
  services.gvfs.enable = true;

  # I did read the comment
  system.stateVersion = "24.11";
}
