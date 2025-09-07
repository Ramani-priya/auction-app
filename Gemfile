# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

gem 'aasm'
gem 'bootsnap', require: false
gem 'devise'
gem 'importmap-rails'
gem 'jbuilder'
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 5.0'
gem 'pundit'
gem 'rails', '~> 7.0.8'
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-cron'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'sassc-rails'
gem "haml-rails"

group :development, :test do
  gem 'database_cleaner-active_record'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.1'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end