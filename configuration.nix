{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./fluent-bit.nix
      ./wazuh-agent.nix
      ./vaultwarden.nix
      ./wireguard.nix
      ./nginx.nix
      ./fail2ban.nix
      ./suricata.nix
    ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024;
  }];

  sops.secrets."user_password" = {
    neededForUsers = true;
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/home/tim/.config/sops/age/keys.txt";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "VW"; # Define your hostname.
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tim = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user_password".path;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      btop
      vim
      tmux
      sops
    ];
  };

  environment = {
    shellAliases = {
      sops-edit = "sudo SOPS_AGE_KEY_FILE=/home/tim/.config/sops/age/keys.txt sops";
      vi = "nvim";
      vim = "nvim";
    };
    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
      SOPS_EDITOR = "vim";
    };
  };

  nix.settings.trusted-users = [ "root" "tim" ];

  users.users.root.hashedPassword = "!";
  programs.neovim.enable = true;
  programs.nano.enable = false;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    suricata
  ];


  # List services that you want to enable:

  services.tailscale.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}
