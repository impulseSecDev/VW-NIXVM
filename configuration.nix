{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #./fluent-bit.nix
      #./wazuh-agent.nix
      # ./vaultwarden.nix
       ./wireguard.nix
       ./nginx.nix
       ./fail2ban.nix
       ./suricata.nix
    ];

  zramSwap.enable = true; # Highly recommended for 4GB/8GB Pis

# Use the generic boot loader.
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

# Standard nonfree rasberry pi firmware.
  hardware.enableRedistributableFirmware = true;

  services.openssh = {
    enable = false;
    openFirewall = false;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "tim" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };

  boot.kernelParams = [ "nomodeset" ];

  sops.secrets."user_password" = {
    neededForUsers = true;
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/keys.txt";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking.hostName = "vw"; # Define your hostname.
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
    sops-edit = "sudo SOPS_AGE_KEY_FILE=\"/var/lib/sops-nix/keys.txt\" sops";
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

  services.tailscale = {
    enable = true;
  };

  boot.zfs.forceImportRoot = false;

  system.stateVersion = "26.05"; # Did you read the comment?


}
