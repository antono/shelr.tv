source 'http://rubygems.org'

gem 'rake'
gem 'unicorn'

gem 'rails', '~> 4.2'
gem 'haml-rails'
gem 'rdiscount'
gem 'kaminari'

gem 'draper'
gem 'simple_form'

gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'

gem 'mongoid', '~> 4.0'
gem 'mongoid_rails_migrations'
gem 'bson_ext'

gem 'sitemap_generator'

# Search
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'sunspot_mongo', git: 'https://github.com/derekharmel/sunspot_mongo.git'
gem 'progress_bar'

gem 'sass-rails'
gem 'uglifier'

gem 'airbrake'

# Markdown + Syntax highlighting
gem 'redcarpet'
gem 'albino'
gem 'rails_markitup', github: 'Gonzih/rails_markitup', branch: 'rails31'

# Gems used only for assets and not required
group :assets do
  gem 'rails-backbone'
  gem 'underscore-rails'
  gem 'jquery-rails'
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'compass_twitter_bootstrap'
end

group :linux do
  gem 'libnotify'
end

group :development, :test do
  gem 'fivemat'

  gem 'factory_girl_rails'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-bundler'

  gem 'pry'
  gem 'pry-nav'

  gem 'turnip'
  gem 'capybara'
  gem "chromedriver-helper"
  gem 'database_cleaner'

  gem 'rspec'
  gem 'rspec-rails'
  # gem 'mongoid-rspec'
  gem 'shoulda-matchers'
  gem 'sunspot_matchers'

  gem 'test-unit'
  gem 'minitest'
end

group :development do
  gem 'foreman'
  gem 'capistrano'
end
