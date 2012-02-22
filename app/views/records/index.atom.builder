atom_feed :language => 'en-US' do |feed|
  feed.title "Shelr.tv - records"
  feed.updated @records.first.created_at

  @records.each do |item|
    feed.entry(item) do |entry|
      entry.url record_url(item)
      entry.title item.title
      entry.content item.description_html, :type => 'html'

      # the strftime is needed to work with Google Reader.
      entry.updated((item.updated_at or item.created_at).strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name item.user.nickname
        author.url user_url item.user
      end
    end
  end
end
