FROM ruby:3.4.5-alpine AS base

ENV LANG=C.UTF-8

RUN apk add --no-cache build-base yaml yaml-dev libsodium tzdata git && rm -rf /var/cache/apk/*

RUN addgroup -S nonroot && adduser -S nonroot -G nonroot

ENV HOME=/contact_gateway
RUN mkdir $HOME

# Configure app home directory
WORKDIR $HOME

COPY ./Gemfile $HOME/Gemfile
COPY ./Gemfile.lock $HOME/Gemfile.lock

ENV RAILS_ENV=production

RUN bundle config set --local without 'development test' && \
      bundle install --jobs 4 --retry 3 && \
      rm -rf /usr/local/bundle/bundler/gems/aca_entities-*/hugo && \
      rm -rf /usr/local/bundle/bundler/gems/aca_entities-*/spec && \
      rm -rf /usr/local/bundle/bundler/gems/event_source-*/spec && \
      rm -rf /usr/local/bundle/bundler/gems/event_source-*/hugo && \
      rm -rf /usr/local/bundle/bundler/gems/resource_registry-*/spec && \
      rm -rf /usr/local/bundle/bundler/gems/resource_registry-*/doc

FROM base AS deploy

COPY . $HOME
COPY ./config/mongoid.yml.production .config/mongoid.yml

RUN chown -R nonroot:nonroot $HOME

USER nonroot
