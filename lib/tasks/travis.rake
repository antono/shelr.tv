namespace :travis do
  desc "Setup travis-ci environment and run specs"
  task :build => :environment do
    cp Rails.root.join('config/config.yml.travis'), Rails.root.join('config/config.yml')
    Rake.application[:spec].invoke
  end
end
