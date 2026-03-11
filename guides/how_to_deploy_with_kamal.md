---
prev: false
next: false
---

# Deploy with Kamal

[Kamal](https://kamal-deploy.org) deploys Docker containers to your own servers via SSH. It handles zero-downtime deploys, SSL certificates, and rolling restarts out of the box.

This guide walks through deploying an Alchemy app with Kamal, based on a real production setup.

### Prerequisites

- A server with SSH access (e.g. Hetzner, DigitalOcean, AWS EC2)
- A container registry account (GitHub Container Registry, Docker Hub, etc.)
- Docker running locally (unless building in CI/CD)

## Install Kamal

Add Kamal to your Gemfile and run the initializer to generate the config files:

~~~bash
bundle add kamal
bin/kamal init
~~~

## Dockerfile

Kamal deploys Docker images, so you need a `Dockerfile`. Rails 7.1+ generates one for you. The key parts for Alchemy:

~~~dockerfile
FROM docker.io/library/ruby:3.4.8-slim AS base
WORKDIR /rails

# Install runtime packages including an image processor
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ... build stage installs gems and precompiles assets ...

# Precompile assets without requiring credentials
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ... final stage copies built artifacts ...

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
~~~

:::tip
Make sure `libvips` (or `imagemagick`) is in the base image's package list. Without it, image rendering will fail in production.
:::

The entrypoint script should run database preparation on startup:

~~~bash
#!/bin/bash -e

if [ "${@: -2:1}" == "./bin/rails" ] && [ "${@: -1:1}" == "server" ]; then
  ./bin/rails db:prepare
fi

exec "${@}"
~~~

This runs `db:prepare` only when starting the web server, which handles both initial setup and migrations.

## Kamal configuration

Configure `config/deploy.yml`:

~~~yaml
service: my-alchemy-app
image: your-registry-user/my-alchemy-app

servers:
  web:
    - 203.0.113.1  # your server IP

proxy:
  ssl: true
  hosts:
    - example.com
    - www.example.com

registry:
  server: ghcr.io
  username: your-github-user
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true

volumes:
  - "my_alchemy_app_storage:/rails/storage"

asset_path: /rails/public/assets

builder:
  arch: amd64
~~~

Key settings:

- **`proxy.ssl: true`** -- Kamal's proxy automatically obtains Let's Encrypt certificates
- **`volumes`** -- Persists SQLite databases, Active Storage files, and cache across deploys
- **`asset_path`** -- Bridges assets between old and new versions during deploy to avoid 404s on in-flight requests
- **`builder.arch`** -- Set to `amd64` if your server runs x86_64 (common for most VPS providers)

## Secrets

Edit `.kamal/secrets` to pull secrets from environment variables or a password manager:

~~~bash
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$RAILS_MASTER_KEY
~~~

:::warning
Never commit `config/master.key` to git. Pass it through secrets instead.
:::

Add any additional secrets your app needs to this file and reference them in the `env.secret` list in `config/deploy.yml`.

## Database setup

For a simple deployment, SQLite with a persistent Docker volume works well. The `volumes` entry in `config/deploy.yml` ensures the database survives deploys:

~~~yaml
volumes:
  - "my_alchemy_app_storage:/rails/storage"
~~~

For PostgreSQL or MySQL, configure an accessory in `config/deploy.yml` or use an external managed database and set `DB_HOST` in your environment.

The entrypoint's `db:prepare` handles both initial creation and subsequent migrations automatically.

## Storage

For **local disk storage**, the Docker volume mount keeps files persistent. This is the simplest option for single-server deployments.

For **remote storage** (S3, GCS, Azure), configure ActiveStorage as described in the [Deployment](deployment#remote-storage) guide. Remote storage is required if you run multiple servers or want files to survive a server replacement.

## First deploy

~~~bash
bin/kamal setup
~~~

This will:
1. Install Docker on your server (if needed)
2. Start the Kamal proxy
3. Build and push your Docker image
4. Start the container
5. Run the entrypoint (which calls `db:prepare`)

Verify by visiting your domain. If you configured `proxy.ssl`, HTTPS should work automatically.

## Subsequent deploys

~~~bash
bin/kamal deploy
~~~

Kamal performs zero-downtime deploys by default: it starts the new container, waits for it to pass health checks, then stops the old one.

## Useful commands

~~~bash
# Open a Rails console on the server
bin/kamal console

# Tail production logs
bin/kamal logs -f

# Run a one-off command
bin/kamal app exec "bin/rails alchemy:generate:thumbnails"

# SSH into the running container
bin/kamal app exec -i bash
~~~

You can define these as aliases in `config/deploy.yml`:

~~~yaml
aliases:
  console: app exec --interactive --reuse "bin/rails console"
  logs: app logs -f
~~~

## Destinations

Kamal destinations let you deploy the same app to different environments. Create a destination-specific config file for each stage:

~~~yaml
# config/deploy.staging.yml
servers:
  web:
    - 203.0.113.2  # staging server

proxy:
  ssl: true
  hosts:
    - staging.example.com
~~~

~~~yaml
# config/deploy.production.yml
servers:
  web:
    - 203.0.113.1  # production server

proxy:
  ssl: true
  hosts:
    - example.com
    - www.example.com
~~~

Deploy to a specific destination with the `-d` flag:

~~~bash
bin/kamal setup -d staging
bin/kamal deploy -d production
~~~

Each destination gets its own containers and proxy configuration on the target server. Secrets can also be scoped per destination using `.kamal/secrets.staging` and `.kamal/secrets.production`.

## CI/CD

You can trigger Kamal deploys from GitHub Actions or any CI system. A minimal workflow:

~~~yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bin/kamal deploy
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
~~~

:::tip
The [Kamal documentation](https://kamal-deploy.org) covers additional topics like rolling deploys, accessories, and multi-server setups.
:::
