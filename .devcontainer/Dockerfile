FROM ruby:4.0

RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    libjemalloc2 \
    libvips \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=libjemalloc.so.2
ENV RUBY_YJIT_ENABLE=1

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /workspace

COPY Gemfile Gemfile.lock* alchemy_cms.gemspec ./
COPY lib/alchemy/version.rb lib/alchemy/version.rb
RUN bundle install

COPY package.json bun.lock* ./
RUN bun install
