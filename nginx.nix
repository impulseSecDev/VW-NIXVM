{ config, pkgs, ... }:

{
  sops.secrets = {
    "cloudflare_api_token" = {
      owner = config.users.users.acme.name;
    };
    "acme_email" = {
      owner = config.users.users.acme.name;
    };
  }; 

  sops.templates."acme.env" = {
    content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare_api_token"}
      LEGO_EMAIL=${config.sops.placeholder."acme_email"}
    '';
    path = "/run/secrets/acme.env";
    mode = "0440";
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "placeholder@mesh.com";
      environmentFile = config.sops.templates."acme.env".path;
    };
      certs = {
        # Name the cert bundle for the root or a specific service
        "mesh.loranjennings.com" = {
          # This issues a wildcard that covers *.mesh...
          domain = "*.mesh.loranjennings.com";
          dnsProvider = "cloudflare";
          credentialFiles = {
            "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_token".path;
          };
          group = "nginx";
        };
        "safe.loranjennings.com" = {
          dnsProvider = "cloudflare";
          credentialFiles = {
            "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_token".path;
          };
          group = "nginx";
        };
     };
  };

  services.nginx = {
    enable = true;
    commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=flood_control:10m rate=1r/s;
    '';
    virtualHosts = {
      # Default Fallback for HTTP (Port 80)
      "default-http-fallback" = {
        default = true; # Catches all traffic not matched by other virtual hosts
        listen = [ { addr = "100.64.0.9"; port = 80; } ];
        extraConfig = ''
          server_name _;
          error_page 400 401 402 403 404 405 429 497 500 =444 /;
          return 444;
        '';
      };

      # Default Fallback for HTTPS (Port 443)
      "default-https-fallback" = {
        default = true; # Catches all traffic not matched by other virtual hosts
        listen = [ { addr = "100.64.0.9"; port = 443; ssl = true; } ];
        extraConfig = ''
          server_name _;
          ssl_reject_handshake on; # Reject non-SSL attempts
          error_page 400 401 402 403 404 405 429 497 500 =444 /;
          return 444;
        '';
      };

      "vw.mesh.loranjennings.com" = {
        useACMEHost = "mesh.loranjennings.com";
        forceSSL = true;
        listen = [ { addr = "100.64.0.9"; port = 443; ssl = true; } ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:8222";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
      };

      "safe.loranjennings.com" = {
        useACMEHost = "safe.loranjennings.com";
        forceSSL = true;
        listen = [
          { addr = "10.10.20.2"; port = 443; ssl = true; proxyProtocol = true; }
        ];

        extraConfig = ''
          set_real_ip_from 10.10.20.3;
          real_ip_header proxy_protocol;

          client_max_body_size 525M;

          proxy_intercept_errors on;
          error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 425 426 428 429 431 451 = @drop;
          limit_req_status 429;
        '';

        locations = {
          "@drop".extraConfig = "return 444;";

          "~ /\\.".extraConfig = ''
            access_log off;
            log_not_found off;
            return 444;
          '';

          "^~ /admin".extraConfig = "return 444;";

          "~* \"(\\.env|\\.git|\\.htaccess|wp-login|wp-admin|phpMyAdmin|adminer|\\.php$)\"".extraConfig = "return 444;";
          "~* \"^/cgi-bin\"".extraConfig = "return 444;";
          "~* \"\\.(sh|bash|py|pl|exe|bat)$\"".extraConfig = "return 444;";

          "/" = {
            proxyPass = "http://127.0.0.1:8222";
            proxyWebsockets = true;
            extraConfig = ''
              limit_req zone=flood_control burst=20 nodelay;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_read_timeout 300s;
            '';
          };
        };
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 443 ];
  networking.firewall.interfaces."wg1".allowedTCPPorts = [ 80 8080 443 ];
}
