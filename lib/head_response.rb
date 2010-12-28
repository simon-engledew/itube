module Net
  class HTTP
    def self.head_response(url)
      URI::parse(url).tap do |uri|
        Net::HTTP.start(uri.host, 80) do |http|
          return http.head(uri.select(:path, :query).join('?'))
        end
      end
    end
  end
end