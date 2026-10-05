{ config, pkgs, ... }: {

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "noatime" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "ext4";
      options = [ "noatime" "noauto" "x-systemd.automount" "x-systemd.device-timeout=30" ];
    };
    "/var" = {
      device = "/dev/disk/by-label/VAR";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
}
