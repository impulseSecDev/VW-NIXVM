{ config, pkgs, ... }: {
  boot.initrd.availableKernelModules = [ "usb_storage" ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "noatime" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" "noauto" "x-systemd.automount" "x-systemd.device-timeout=30" ];
    };
    "/var/lib/vaultwarden" = {
      device = "/dev/disk/by-uuid/e5c9ec40-8d0f-4588-92b9-498e0142d070";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
}
