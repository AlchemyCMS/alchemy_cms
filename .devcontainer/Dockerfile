ARG RUBY_VERSION=4.0.5

# Builder stage: compiles native gem extensions and installs JS dependencies.
# The compiler toolchain lives here only, so it never ends up in the final image.
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable

WORKDIR /workspace

COPY Gemfile Gemfile.lock* alchemy_cms.gemspec ./
COPY lib/alchemy/version.rb lib/alchemy/version.rb
RUN bundle install

COPY package.json pnpm-*.yaml ./
RUN pnpm install

# Runtime stage: only the libraries the app needs to run. No compiler toolchain
# and no ImageMagick (image processing uses libvips via the active_storage
# adapter). Gems and node_modules are copied from the builder.
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

RUN apt-get update && apt-get install -y \
    curl \
    git \
    libjemalloc2 \
    libvips \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable

ENV LD_PRELOAD=libjemalloc.so.2
ENV RUBY_YJIT_ENABLE=1
ENV LISTEN_GEM_ADAPTER_WARN_BEHAVIOR=silent

WORKDIR /workspace

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /workspace/node_modules /workspace/node_modules
