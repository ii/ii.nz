# Deployment

## Background

ii.nz is deployed to a fleet of Raspberry Pis hosted locally across Aotearoa New Zealand.
It is deployed through Balena Cloud and served through Cloudflare.
The site is tracked through git stored on GitHub.

We chose the set of technologies with the idea for something that we can self-host on our own infrastructure and make it easy to understand and maintain.

### Hugo

A static site generator, which allows for separate focuses on content and site layouts.
It supports markdown and org-mode, amongst other things for content format.

Static sites are easier to maintain than stateful sites, such as standard Wordpress or Ghost due to the lack of a database and need to backup.

This is chosen given it's easy of use and familiarity.

### Balena

An IoT platform, which allows for deploying applications as containers to fleets of edge/IoT devices.

This is chosen as it provides a fresh look at instant infrastructure and is simple enough to use.

It also provides a simplified method providing replicated deployment across many devices in a fleet, with no-configuration provisioning of devices.

### Raspberry Pis

Cheap, ubiquious and low-power devices which support BalenaOS.
ii has many of them and so do members of the team.

### Cloudflare

For running this site, Cloudflare Tunnels allows for balancing the traffic across all devices in the fleet which provides greater stability.

With the [`cloudflared`](https://github.com/cloudflare/cloudflared) agent running on each device in the fleet, Cloudflare will serve from the [geographically closest one](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/deploy-cloudflared-replicas/#cloudflared-replicas).

There is also a level of caching happening with the _proxied_ DNS records.

### GitHub Actions

GitHub is used to work out of and Balena Cloud provides a git repository which is used to build new revisions but is not for general code storage.
Balena Cloud supports either API or git and using git is the easiest option to tie the two together.

GitHub Actions is used for pushing the repo's latest commit to the Balena Cloud repository.

## Provisioning a device in the fleet

In Kubernetes terms, a fleet is like a _Cluster_ of Nodes where applications are deployed like a DaemonSet.

A new device can be added to the fleet with the following:

1. navigate to https://dashboard.balena-cloud.com
2. select the organisation `balenacloud90`
3. select fleets and fleet `ii-nz`
4. select devices
5. select add device
6. add a device with the following settings

> device type: Raspberry Pi 4 (using 64bit OS) or the device type required
> version: the latest available
> edition: production
> network connection: which ever is more suitable, although ethernet only is likely more stable

7. select the blue _flash_ or _download BalenaOS_ button

links:
- https://docs.balena.io/learn/getting-started/raspberrypi5/nodejs/#add-a-device-and-download-os

## Cloudflare tunnels

Authorise and create a tunnel with the following commands

```sh
$ cloudflared tunnel login

$ cloudflared tunnel create ii-nz
```

A JSON file will be produced with the credentials to connect the said tunnel.

```
$ cloudflared tunnel list -o json | jq -r '.[] | select(.name=="ii-nz") | .id' \
  | head -n 1 | xargs -I{} cat $HOME/.cloudflared/{}.json | base64
```

base64 encode the file, and park them for later.

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

## Misc

### Create a new record pointing to the tunnel

```sh
$ cloudflared tunnel route dns ii-nz SOME_SUBDOMAIN.ii.nz
```

note: to serve with a completely different config, a new tunnel must also be created.

### Setup a local host

(instructions WIP)

```sh
$ export TUNNEL_NAME=preview-from-${CFT_NAME:-$USER}s-machine-ii-nz
$ cloudflared tunnel create "$TUNNEL_NAME"
$ export CF_CREDS="$(cloudflared tunnel list -o json | jq --arg TUNNEL_NAME "$TUNNEL_NAME" -r '.[] | select(.name==$TUNNEL_NAME) | .id' \
  | head -n 1 | xargs -I{} cat $HOME/.cloudflared/{}.json | base64)"
$ export TUNNEL_ID="$(cloudflared tunnel list -o json | jq --arg TUNNEL_NAME "$TUNNEL_NAME" -r '.[] | select(.name==$TUNNEL_NAME) | .id')"
$ cloudflared tunnel route dns "$TUNNEL_NAME" "$TUNNEL_NAME".ii.nz
$ yq e -i '.tunnel=env(TUNNEL_ID) | .ingress[0].hostname=env(TUNNEL_NAME)+".ii.nz"' cloudflared-config.yaml
```
