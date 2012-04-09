# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

begin
  require 'sitemap_generator/tasks'
rescue Exception => e
  puts "Warning, couldn't load gem tasks: #{e.message}! Skipping..."
end

Shelr::Application.load_tasks
