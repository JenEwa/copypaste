# Variables

Every variable a consumer of `nachtkrabb.traefik_service_proxy` can set, with
its default. None is needed to deploy the proxy: applying the `traefik` role
with nothing set gives a working Traefik on `:8080`/`:8443` behind the host
firewall's 80/443 redirects. Only `traefik_register_service` has a required
input.

A blank or null value counts as unset and takes the default, with one
exception: `traefik_redirect_to_https: false` turns the redirect off.

`docs/defaults.yml` is the same list in YAML form.

## Proxy roles

Applied through the `traefik` role, which runs `common`, `firewall`,
`account`, `config_volume`, `certstore_volume` and `container` in that order.
Every variable below applies the same way whether a role is named on its own
or through `traefik`.

| Variable | Role | Default | Effect |
| --- | --- | --- | --- |
| `traefik_web_address` | `firewall`, `config_volume` | `":8080"` | address of the `web` entrypoint; quoted, must end `:port`, port 1024-65535 |
| `traefik_websecure_address` | `firewall`, `config_volume` | `":8443"` | address of the `websecure` entrypoint; same rules |
| `traefik_entrypoints` | `firewall`, `config_volume` | `{}` | extra entrypoints as `name: ":port"` (`/udp` allowed); must not name `web` or `websecure`; each port is opened in the firewall |
| `traefik_redirect_to_https` | `config_volume` | `true` | redirect everything on `web` to `:443`; set `false` on a proxy with no certificate |
| `traefik_cert_resolvers` | `config_volume` | `{}` | rendered verbatim as `certificatesResolvers`; keep secrets out, see the README |
| `traefik_log_level` | `config_volume` | `INFO` | Traefik's log level |
| `traefik_tls_certificates` | `config_volume` | `[]` | proxy-wide certificates, as `certFile`/`keyFile` container paths under `/etc/traefik`; the files must already be in the volume |
| `traefik_env_file_content` | `container` | `""` | content of the unit's environment file, `0600`; blank writes no `EnvironmentFile=` |
| `traefik_image` | `container` | the pinned tag in `roles/container/defaults/main.yml` | Traefik image; Renovate bumps the pin. A changed image backs up both volumes to the manual tier first |
| `common_traefik_user` | `common` | `traefik` | account that runs the Traefik quadlet |
| `common_config_volume` | `common` | `traefik-config` | named volume mounted read-only at `/etc/traefik` |
| `common_certstore_volume` | `common` | `traefik-certstore` | named volume mounted read-write at `/var/lib/traefik` |

The container-side paths in `common` (`common_config_dir`,
`common_dynamic_dir`, `common_static_config`, `common_certs_dir`,
`common_certstore_dir`) are settable but describe mount points inside the
container; changing them is not supported.

Two test-only switches default to production behaviour and should stay unset
on a real host: `common_service_manage` (`true`: start and restart the unit)
and `traefik_sysctl_apply` (`true`: apply the port-floor sysctl live).

## Registering a workload

`traefik_register_service` is applied once per workload account, in the
workload's own play, and `audit` after it. `audit` takes no variables.

| Variable | Default | Effect |
| --- | --- | --- |
| `traefik_register_service_account` | none, **required** | the rootless account whose quadlet directory is read |
| `traefik_register_service_certificates` | `[]` | certificates the workload brings, see below |

Each certificate entry has a `name` (required, `^[A-Za-z0-9._-]+$`, becomes
the file name under `certs/`) and either content or a Keeper record, never
both:

```yaml
traefik_register_service_certificates:
  - name: app
    certificate: "{{ lookup('file', 'app.crt') }}"
    key: "{{ lookup('file', 'app.key') }}"
  - name: other
    keeper:
      uid: <record uid>                  # required
      certificate_file: fullchain.pem    # default; or certificate_field: <custom field>
      key_file: privkey.pem              # default; or key_field: <custom field>
```

A Keeper entry needs, on the controller, the
`keepersecurity.keeper_secrets_manager` collection, the
`keeper-secrets-manager-core` pip package, and `keeper_config` (base64) or
`keeper_config_file` (a path) as an Ansible variable. `KSM_CONFIG` in the
environment is not read.

## Read from other collections

The proxy roles apply roles of `nachtkrabb.podman`, so these apply too:

| Variable | Default | Effect |
| --- | --- | --- |
| `ansible_port` | `22` | the firewall always keeps this port open; set it when the SSH port is only in an ssh client config |
| `podman_userns_sysctl_set` | `true` | Ubuntu 26.04 only: apply the rootless user-namespace sysctl live |

The account name, the firewall ports and redirects, and the backup inputs are
computed by this collection and passed on; they are not consumer-set.
