# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.4'

# Gems that have trouble with native packages on alpine.
gem 'google-protobuf', force_ruby_platform: true
gem 'nokogiri', force_ruby_platform: true

gem 'rails', '~> 8'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma'

gem 'parslet'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'rack', '~> 3.1'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Used for uploading files to Digital Ocean Spaces
gem 'aws-sdk-s3'

# Used for our import of the card data.
gem 'activerecord-import'

# Base for our JSON API.
gem 'graphiti'
gem 'graphiti-rails'
gem 'kaminari', '~> 1.0'
gem 'ostruct'
gem 'responders'

# Views
gem 'scenic'

gem 'apitome'
gem 'jwt'
# Upstream is unmaintained; Rack 3.1 / Ruby 3.2+ fixes live in
# spec/support/rspec_api_documentation_patches.rb.
gem 'rspec_api_documentation', '6.1.0'
gem 'sprockets-rails'

# Observability and monitoring via OpenTelemetry.
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'
gem 'opentelemetry-sdk'

# for review imports from NRDBc
gem 'reverse_markdown'

# for structured JSON logging.
gem 'rails_semantic_logger'

group :development, :test do
  gem 'brakeman'
  # Lock to 8.0.3 because we don't have CSP middleware and the next version crashes without it.
  gem 'bullet'
  gem 'bundler-audit'
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'graphiti_spec_helpers'
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
  gem 'ruby-lsp-rails', require: false
  gem 'ruby-lsp-rspec', require: false
  gem 'simplecov'
  gem 'simplecov-cobertura'
  gem 'sqlite3', '~> 2.9'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
