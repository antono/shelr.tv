atom_feed :language => 'en-US', :id =>  "tag:#{request.host}:#{request.fullpath.split(".")}:#{params[:q]}" do |feed|
  feed.title "Shelr.tv - feed for '#{params[:q]}'"

  # TODO: records sorted by relevancy so it's not relly
  #       last one... probably we should sort by date for search
  if @records.any?
    feed.updated @records.first.created_at
    feed.tag!("openSearch:totalResults", @records.size)
  end


  @records.each do |item|
    feed.entry(item) do |entry|
      entry.url record_url(item)
      entry.title item.title
      entry.content item.description_html, :type => 'html'
      entry.updated((item.updated_at or item.created_at).strftime("%Y-%m-%dT%H:%M:%SZ")) 
      entry.author do |author|
        author.name item.user.nickname
        author.url user_url item.user
      end
    end
  end
end

# Local Variables:
# mode: ruby
# End:
