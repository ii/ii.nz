# Deployment

## Cloudflare tunnels

Authorise and create a tunnel with the following commands

```sh
$ cloudflared tunnel login

$ cloudflared tunnel create ii-nz
```

A JSON file will be produced with the credentials to connect the said tunnel.

```
find $HOME/.cloudflared/ -maxdepth 1 -type f -name '*.json' \
  | head -n 1 | xargs cat | base64
```

base64 encode the file, and park for later.

### links
- https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/
- https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/deploy-cloudflared-replicas/

## SSH keys

Generate an SSH key, like so

```sh
$ ssh-keygen -t ed25519 -f balenacloud90ci
```

## Balena Cloud

Setting up the SSH key:

1. Navigate to https://dashboard.balena-cloud.com/preferences/sshkeys, logged in as the balenacloud ii user.
2. Add a new SSH key, with contents of `cat balenacloud90ci.pub` (public key) and titled `balenacloud90ci`

Setting the cloudflare tunnels variable

1. Navigate to Organisations -> balenacloud90 -> Fleets -> ii-nz -> Variables
2. Set a variable called `CF_CREDS` with the value of the base64-encoded contents from creating a tunnel

## GitHub Actions

1. Navigate to https://github.com/ii/nz/settings/secrets/actions
2. Add a new repository secret called `SSH_KEY_FILE`, with the contents of `cat balenacloud90ci | base64` (base64 encoded private key)

## docker-compose setup

A multi-container deployment for serving the site.

Please pin all software versions, e.g: container images, build dependencies.

A volume is used for holding the credentials between the `cfcfg` container and `cloudflared` container.

### `ii-nz`

a Hugo-built site with a web server listening on 8080.

The webserver is currently [go-http-server](https://gitlab.com/BobyMCbobs/go-http-server) but could be swapped out for a rootless nginx.

### `cfcfg`

an `initContainer` for writing cloudflare creds to a volume for file-based consumption.

### `cloudflared`

the cloudflare daemon for serving tunnels, configured to host ii.nz.

It's config under `ingress[].service` must use the local address for the ii-nz container, being http://ii-nz:8080, based on the container service name.
