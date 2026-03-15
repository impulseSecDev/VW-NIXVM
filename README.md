# Vaultwarden VM

> Self-hosted Bitwarden-compatible password manager running on NixOS — fully declarative, version-controlled, via private and public HTTPS access.

Part of the [Homelab Security Stack](https://github.com/impulseSecDev/homelab-security-stack).

---

## Overview

The Vaultwarden VM runs a self-hosted Bitwarden-compatible password manager as a daily-use service. It is never directly internet-exposed — public access routes through the VPS Nginx reverse proxy over a dedicated WireGuard tunnel. Internal tailnet access routes directly over Tailscale.

The entire VM state is declared in NixOS configuration. Secrets are managed via sops-nix — no plaintext credentials in version control.

---

## Stack

| Component | Version | Method |
|---|---|---|
| Vaultwarden | Latest | Native NixOS service |
| Nginx | — | Native NixOS module |
| Wazuh Agent | 4.14.3 | Native NixOS service |
| Fluent Bit | 4.x | Native NixOS module |
| WireGuard | — | Native NixOS module |
| sops-nix | — | Encrypted secrets management |

---

## Access Paths

Two distinct access paths, both HTTPS end-to-end. The Vaultwarden VM is never directly internet-exposed in either path.

| User Type | Path |
|---|---|
| Tailnet members | Device → Tailscale → Vaultwarden VM Nginx (HTTPS) → Vaultwarden |
| External users (friends/family) | Device → HTTPS → VPS Nginx → WireGuard (wg1) → Vaultwarden VM Nginx (HTTPS) → Vaultwarden |

---

## Network

### Tailscale

The Vaultwarden VM is a full member of the Tailscale mesh. Internal access for tailnet members routes directly over Tailscale to the VM's Nginx instance — no VPS relay involved.

### WireGuard

Two dedicated WireGuard interfaces:

| Interface | Purpose |
|---|---|
| wg0 | Log shipping — Fluent Bit and Wazuh agent comms to VPS hub |
| wg1 | Public access routing — VPS Nginx forwards external traffic to this VM |

All WireGuard connections initiate outbound — no inbound ports required on the home router.

### TLS

Wildcard certificate for `*.mesh.yourdomain.com` provisioned automatically via the NixOS `security.acme` module using Cloudflare DNS-01 challenge validation. Fully automated renewal — no manual certificate management. Both Nginx virtual hosts use this certificate.

---

## NixOS Module Structure

```
nixos/
├── configuration.nix        # Entry point, imports all modules
├── hardware-configuration.nix
├── flake.nix
├── vaultwarden.nix          # Vaultwarden service, environment config
├── nginx.nix                # HTTPS reverse proxy, dual virtual hosts
├── acme.nix                 # Wildcard TLS cert via Cloudflare DNS-01
├── fluent-bit.nix           # Fluent Bit with sops template
├── wireguard.nix            # wg0 log shipping, wg1 public routing
├── wazuh-agent.nix          # Wazuh agent, enrollment config
├── sops.nix                 # sops-nix configuration
└── secrets/
    └── secrets.yaml         # sops-encrypted secrets (safe to commit)
```

---

## Persistent Data

Vaultwarden data is stored on the host and survives service restarts:

```
/var/lib/vaultwarden/     # SQLite database, attachments, sends
/var/local/vaultwarden/
└── backup/               # Built-in SQLite backup (automated)
```

---

## Defense in Depth

- Vaultwarden never directly internet-exposed — all public access proxied via VPS
- TLS on all access paths — both Tailscale and public routes terminate HTTPS at this VM
- Wazuh agent monitors the VM — FIM on config files, rootkit detection, SCA
- Fluent Bit ships system logs to Elasticsearch over dedicated WireGuard log shipping channel
- sops-nix encrypted secrets — no plaintext credentials in version control
- Admin panel protected by strong random token — not exposed publicly
- Signups disabled after initial account creation

---

## Tech Stack

`NixOS` `Vaultwarden` `Nginx` `WireGuard` `Tailscale` `Fluent Bit` `Wazuh` `sops-nix` `ACME / Let's Encrypt` `Cloudflare DNS-01` `TLS / HTTPS` `Declarative infrastructure`
