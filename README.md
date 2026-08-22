# acme-please 📜

ACME client onboarding and certificate lifecycle for the whole fleet —
**enterprise-EAB first**, internal CAs and Let's Encrypt supported, and
every client installed from a **native package channel** so your normal
patch runs (fleet-medic) keep them updated. No curl-pipe installers,
ever.

```bash
ansible-galaxy collection install mcowser_p.acme_please
```

## Platform matrix

| Platform | Client | Channel | Updated by |
| --- | --- | --- | --- |
| AlmaLinux 9 / 10 | certbot | dnf (EPEL) | patch runs |
| Ubuntu 24.04 / 26.04 | certbot | apt | patch runs |
| Amazon Linux 2023 | certbot | dnf (base) | patch runs |
| Windows Server 2022 / 2025 | simple-acme | winget (bootstrapped on fresh 2022) | fleet-medic's winget step |

Renewal: certbot's packaged systemd timer; simple-acme's own scheduled
task. Windows Server 2019 is not supported (winget cannot run there).

## What one run does

1. Installs the client natively (+ your chosen certbot DNS plugin).
2. Trusts your internal CA root in the OS store when provided.
3. Registers the ACME account — `--eab-kid`/`--eab-hmac-key` when your
   CA requires External Account Binding (the default posture here).
4. Issues each cert in `acme_please_certs` via **dns-01** (plugin or
   your own auth-hook script — works with Microsoft DNS) or http-01.
5. Deploys to the access-profiles canonical paths
   (`/etc/pki/tls/{certs,private}` on EL/AL, `/etc/ssl/{certs,private}`
   on Ubuntu) with correct ownership, key mode 0600, and SELinux
   `cert_t` labelling for non-standard key locations — via a rendered
   **deploy hook** that re-fires on every renewal, rebuilds optional
   PKCS12 keystores (the Tomcat case), and runs your profile-granted
   reload command.
6. On Windows: IIS-sourced or manual-host issuance, renewal task
   asserted.

Troubleshooting the result is the sibling collection's job:
[`mcowser_p.ssl_sleuth`](https://github.com/mcowser-p/ssl-sleuth).

## CI really issues certificates

Molecule runs the full flow against **pebble** (Let's Encrypt's test
CA) with `externalAccountBindingRequired: true` — the EAB path is
proven end-to-end on AlmaLinux 9 & 10, Ubuntu 24.04 & 26.04, and
Amazon Linux 2023, including renewal hook re-firing and a bad-EAB
negative case.

## License

Apache-2.0
