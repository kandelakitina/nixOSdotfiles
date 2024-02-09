# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # bootloader
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # SHELL
  environment.shells = with pkgs; [
    bash
    fish
  ];
  users.defaultUser.shell = pkgs.fish;
  programs.fish.enable = true;

  # networking
  networking = {
    networkmanager.enable = true;
    hostName = "nixos"; # edit this to your liking
  };

  # QEMU-specific - allow copy buffer VM - host
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # locales
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
 
  # graphics
  services.xserver = {
    enable = true;
    # setup the resolution to match your screen
    resolutions = [{ x = 1920; y = 1080; }];
    virtualScreen = { x = 1920; y = 1080; };
    layout = "us"; # keyboard layout
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    autorun = true; # run on graphic interface startup
    libinput.enable = true; # touchpad support
  };

  # audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # USERS
  users.users = {
    # Replace with your username
    boticelli = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "123";
      createHome = true;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # "..."
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = ["wheel"];
    };
  };

  # SSH
  services.openssh.settings = {
    enable = true;
    kexAlgorithms = [ "curve25519-sha256" ];
    ciphers = [ "chacha20-poly1305@openssh.com" ];
    passwordAuthentication = false;
    permitRootLogin = "no"; # do not allow to login as root user
    kbdInteractiveAuthentication = false;
  };

    # list default apps
  environment.systemPackages = with pkgs; [
    helix
    wget
    git
    curl
    btop
  ];

  # some default preferences
  environment.variables = {
    EDITOR = "hx"; 
    VISUAL = "hx";
  };

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      pulseaudio = true;
      allowUnfree = true;
    };

    # overlays = [
    #   # If you want to use overlays exported from other flakes:
    #   # neovim-nightly-overlay.overlays.default
    #   # Or define it inline, for example:
    #   # (final: prev: {
    #   #   hi = final.hello.overrideAttrs (oldAttrs: {
    #   #     patches = [ ./change-hello-to-hi.patch ];
    #   #   });
    #   # })
    # ];
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  # FLAKES SUPPORT
  # nix.settings = {
  #   # Enable flakes and new 'nix' command
  #   experimental-features = "nix-command flakes";
  #   # Deduplicate and optimize nix store
  #   auto-optimise-store = true;
  # };

  # Same but in different syntax
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
