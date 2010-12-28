module ApplicationHelper
  def itunes_namespace
    {
      # 'xmlns:creativeCommons' => "http://backend.userland.com/creativeCommonsRssModule",
      # 'xmlns:media' => "http://search.yahoo.com/mrss/",
      # 'xmlns:geo' => "http://www.w3.org/2003/01/geo/wgs84_pos#",
      # 'xmlns:wfw' => "http://wellformedweb.org/CommentAPI/",
      # 'xmlns:amp' => "http://www.adobe.com/amp/1.0",
      # 'xmlns:dcterms' => "http://purl.org/dc/terms",
      # 'xmlns:gm' => "http://www.google.com/schemas/gm/1.1",
      'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
      'version' => '2.0'
    }
  end
  
  def http_head(url)
    uri = URI::parse(url)

    Net::HTTP.start(uri.host, 80) do |http|
      return http.head(uri.select(:path, :query).join('?'))
    end
  end
end
