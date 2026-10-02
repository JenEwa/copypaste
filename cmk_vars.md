# Variables

Every variable a consumer of `nachtkrabb.checkmk` can set, with its default.
Apply the `checkmk_server` role, which runs `account`, `sites_volume`, `pod`
and `container` in that order, each after `common`. Every input is resolved
once in `roles/common/vars/main.yml`, so a variable applies the same way
whichever role is named.

The only input that is needed is the admin password's source: with the
default source, `keeper`, `checkmk_server_admin_password_keeper_uid` is
required.

A blank or null value counts as unset and takes the default, with two
exceptions: `checkmk_server_manage: false` stops the role starting and
restarting the site, and `checkmk_server_image` is passed on as given.

`docs/defaults.yml` is the same list in YAML form.

## Site

| Variable | Default | Effect |
| --- | --- | --- |
| `checkmk_server_user` | `checkmk` | rootless account that runs the site; must match `^[a-z_][a-z0-9_-]{0,31}$`. Choose it at deployment, do not change it later |
| `checkmk_server_site` | `cmk` | OMD site id; must match `^[a-zA-Z_][a-zA-Z0-9_]{0,15}$`. Choose it at deployment |
| `checkmk_server_image` | the pinned tag in `docs/defaults.yml` | Checkmk image; Renovate bumps the pin. A changed image backs up the sites volume to the manual tier first. Checkmk cannot downgrade a site |
| `checkmk_server_sites_volume` | `checkmk-sites` | podman volume holding `/omd/sites`; must match `^[a-zA-Z0-9][a-zA-Z0-9_.-]*$`. Choose it at deployment |
| `checkmk_server_timezone` | `Europe/Berlin` | the container's `TZ` |
| `checkmk_server_manage` | `true` | start and restart the site; only `false` turns it off |

## Network

| Variable | Default | Effect |
| --- | --- | --- |
| `checkmk_server_listen` | `"127.0.0.1:5000"` | host address of the web interface, `a.b.c.d:port`; a bare port is refused |
| `checkmk_server_publish` | `["127.0.0.1:8001:8000"]` | extra `ip:hostport:containerport` lines on the pod after the web port; the default publishes the agent receiver on host port 8001. `[]` publishes nothing extra. Every entry needs an address |
| `checkmk_server_labels` | `{}` | `Label=` lines on the unit, verbatim, for `nachtkrabb.traefik_service_proxy`; needs `traefik.enable: "true"` to route. Quote booleans; keys must not contain whitespace or `=`. A change restarts the site |

## Admin password

| Variable | Default | Effect |
| --- | --- | --- |
| `checkmk_server_admin_password_source` | `keeper` | `keeper`, `env` or `literal`; anything else is refused |
| `checkmk_server_admin_password_keeper_uid` | none | source `keeper`: **required**, the Keeper Secrets Manager record uid |
| `checkmk_server_admin_password_keeper_field` | `password` | source `keeper`: the record's field label |
| `checkmk_server_admin_password_env` | `CHECKMK_ADMIN_PASSWORD` | source `env`: the **name** of an environment variable on the controller |
| `checkmk_server_admin_password` | none | source `literal`: **required**, the password itself |

A variable belonging to another source is refused, not ignored.

The `keeper` source needs, on the controller, the
`keepersecurity.keeper_secrets_manager` collection, the
`keeper-secrets-manager-core` pip package, and `keeper_config` (base64) or
`keeper_config_file` (a path) as an Ansible variable. `KSM_CONFIG` in the
environment is not read.

## Read from other collections

`account` applies `nachtkrabb.podman.podman_container_user`, which applies
`nachtkrabb.podman.podman`, so this applies too:

| Variable | Default | Effect |
| --- | --- | --- |
| `podman_userns_sysctl_set` | `true` | Ubuntu 26.04 only: apply the rootless user-namespace sysctl live |

The account name and the backup inputs are computed by this collection and
passed on; they are not consumer-set.
