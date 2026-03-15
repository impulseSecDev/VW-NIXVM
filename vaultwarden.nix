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
    '';
    path = "/run/secrets/vaultwarden.env";
    mode = "0400";
    owner = "root";
    group = "root";
  };  


  services.vaultwarden = {
    enable = true;
    backupDir = "/var/local/vaultwarden/backup";
    # in order to avoid having  ADMIN_TOKEN in the nix store it can be also set with the help of an environment file
    # be aware that this file must be created by hand (or via secrets management like sops)
    environmentFile = [ config.sops.templates."vaultwarden.env".path ];
    config = {
      # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };  
}
