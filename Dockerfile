# Inspired by https://dennmart.com/articles/building-lean-docker-images-for-rails-apps/

#####################################################################
FROM ruby:3.4-alpine3.24 AS build

RUN apk -U upgrade && apk add --no-cache gcompat git postgresql-client build-base libpq-dev tzdata yaml-dev \
  && rm -rf /var/cache/apk/*

RUN gem install rails

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/nrdb-api

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY Gemfile Gemfile.lock $RAILS_ROOT/

# Install gems into the vendor/bundle directory in the workspace.
RUN bundle config set --local path "vendor/bundle" && \
  bundle config set force_ruby_platform true && \
  bundle install --jobs 4 --retry 3

COPY . $RAILS_ROOT/


#####################################################################
FROM ruby:3.4-alpine3.24 AS final

RUN apk -U upgrade && apk add --no-cache gcompat git postgresql-client tzdata \
  && rm -rf /var/cache/apk/*

ENV RAILS_ROOT /var/www/nrdb-api
WORKDIR $RAILS_ROOT
RUN bundle config set --local path "vendor/bundle"
COPY --from=build $RAILS_ROOT $RAILS_ROOT/

EXPOSE 3000
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

# Start the main process.
CMD ["/bin/sh", "-c", "bundle exec rails server -b 0.0.0.0"]
