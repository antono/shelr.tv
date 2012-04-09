# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://shelr.tv"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/records'
  #
  add records_path, :priority => 0.7, :changefreq => 'hourly'
  add users_path, :priority => 0.6, :changefreq => 'hourly'
  add '/about', :priority => 0.8, :changefreq => 'weekly'

  Record.find_in_batches(per: 100) do |batch|
    batch.each do |record|
      add record_path(record), :lastmod => record.updated_at
    end
  end
end
