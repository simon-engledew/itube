xml.instruct!
xml.rss(itunes_namespace) do
  xml.channel do
    xml.title(@youtube_feed.title)
    xml.link(@youtube_feed.url)
    xml.image do
      xml.link(@youtube_feed.url)
      xml.url(@youtube_feed.entries.first.summary.css('img').first['src'])
      xml.title(@youtube_feed.title)
    end
    author = @youtube_feed.entries.map{ |entry| entry.author }.to_set.to_a.to_sentence
    xml.description "YouTube feed for #{ author }"
    xml.tag!('itunes:summary', "YouTube feed for #{ author}")
    xml.tag!('itunes:author', author)
    xml.tag!('itunes:block', 'no')
    xml.tag!('itunes:category', :text => 'Games & Hobbies') do
      xml.tag!('itunes:category', :text => 'Video Games')
    end
    xml.language('en')
    xml.generator('appname')
    xml.lastBuildDate(@youtube_feed.last_modified.to_s(:rfc822))
    xml.pubDate(@youtube_feed.last_modified.to_s(:rfc822))
    @youtube_feed.entries.each do |entry|
      response = Cache.read(entry.entry_id) do
        video = Video.new(entry.url)
        http_head(video.url)
      end
      xml.item do
        xml.guid(entry.entry_id, :isPermaLink => 'false')
        xml.link(entry.url)
        xml.title(entry.title)
        xml.tag!('itunes:explicit', 'no')
        xml.description(entry.summary.css('table > tbody > tr:nth-child(1) > td:nth-child(2) > div > span').inner_text)
        xml.category('Gaming')
        xml.pubDate(entry.published.to_s(:rfc822))
        xml.enclosure(:url => video_url(:identifier => video.identifier), :type => response['Content-type'], :length => response['Content-Length'])
        xml.tag!('itunes:keywords', '')
        xml.tag!('itunes:image', entry.summary.css('img').first['src'])
      end
    end
  end
end
