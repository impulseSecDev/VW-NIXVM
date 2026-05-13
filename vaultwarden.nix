{ config, lib, pkgs, ... }:
{
  sops.secrets = {
    "vw_admin_token" = {};
    "vw_domain" = {};
  };

  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vw_admin_token"}
      DOMAIN=${config.sops.placeholder."vw_domain"}
      EXTENDED_LOGGING=true
      LOG_LEVEL=info
      LOG_FILE=/var/lib/vaultwarden/vaultwarden.log
      ORG_EVENTS_ENABLED=true
    '';
    path = "/run/secrets/vaultwarden.env";
    mode = "0400";
    owner = "root";
    group = "root";
  };


  services.vaultwarden = {
    enable = true;
    backupDir = "/var/local/vaultwarden/backup";
    environmentFile = [ config.sops.templates."vaultwarden.env".path ];
    config = {
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
cat: cat: No such file or directory
{ config, lib, pkgs, ... }:
{
  sops.secrets = {
    "vw_admin_token" = {};
    "vw_domain" = {};
  };

  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vw_admin_token"}
      DOMAIN=${config.sops.placeholder."vw_domain"}
      EXTENDED_LOGGING=true
      LOG_LEVEL=info
      LOG_FILE=/var/lib/vaultwarden/vaultwarden.log
      ORG_EVENTS_ENABLED=true
    '';
    path = "/run/secrets/vaultwarden.env";
    mode = "0400";
    owner = "root";
    group = "root";
  };


  services.vaultwarden = {
    enable = true;
    backupDir = "/var/local/vaultwarden/backup";
    environmentFile = [ config.sops.templates."vaultwarden.env".path ];
    config = {
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
