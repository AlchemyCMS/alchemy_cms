ARG RUBY_VERSION=4.0.5

# Base stage: the runtime environment shared by the builder and the final image
# (Node for pnpm, plus the libraries the app links at runtime). Installing these
# once here avoids repeating them in both stages.
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

RUN apt-get update && apt-get install -y \
    curl \
    git \
    libjemalloc2 \
    libvips \
    && rm -rf /var/lib/apt/lists/*

ARG NODE_VERSION=24
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable

WORKDIR /workspace

# Builder stage: the base plus the compiler toolchain needed to build native gem
# extensions. Nothing from this stage reaches the final image except the compiled
# gems and installed node_modules.
FROM base AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Gemfile.lock is a dev artifact; the gemspec is the source of truth. Resolve
# the whole dependency tree fresh to the latest allowed versions on every build.
COPY Gemfile alchemy_cms.gemspec ./
COPY lib/alchemy/version.rb lib/alchemy/version.rb
RUN bundle update --all

COPY package.json pnpm-*.yaml ./
RUN pnpm install

# Final stage: the base environment with the built gems and node_modules copied
# in. No compiler toolchain and no ImageMagick (image processing uses libvips via
# the active_storage adapter).
FROM base

ENV LD_PRELOAD=libjemalloc.so.2
ENV RUBY_YJIT_ENABLE=1
ENV LISTEN_GEM_ADAPTER_WARN_BEHAVIOR=silent

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /workspace/node_modules /workspace/node_modules
