# Ranked voting app ([by me and Claude Sonnet 4](https://claude.ai/share/04f7be83-a18a-4c8a-a4a9-25be43da27b1))

A simple local survey app for taking ranked preferences and saving the data locally.

It creates a container which runs the shiny app and exposes it publicly with [Cloudflare tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/).

## Setup

Requires a [Cloudflare tunnel key](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/) defined in `.env`.

Create a `.env` file with a single line containing your tunnel key:

```
CLOUDFLARE_TUNNEL_TOKEN=xyz
```

**Requires Docker or podman**

```sh
podman build -t voting_app .
```

## Run the app

```sh
podman run --env-file=".env" -v "./data:/data" voting_app
```
