require 'open-uri'

class Video
  class Enclosure
    attr_reader :identifier, :url, :content_type, :length
    
    def initialize(identifier, url)
      response = Net::HTTP.head_response(url)

      @url = url      
      @identifier = identifier
      @content_type = response['Content-type']
      @length = response['Content-Length']
    end
  end
  
  FORMATS = [
    22, # => 'MP4 720p (HD)',
    18, # => 'MP4 360p',
    37, # => 'MP4 1080p (HD)',
    38, # => 'MP4 Original (HD)',
  ]
  
  attr_reader :url, :identifier, :ticket, :formats
  
  def initialize(url)
    document = Feedzirra::Feed.fetch_raw(url)
    
    @url = url
    @identifier = document[/\&video_id=([^(\&|$)]*)/, 1]
    
    Cache[@identifier] = @url
    
    # volatile
    @ticket = document[/\&t=([^(\&|$)]*)/, 1]
    @formats = {}.tap do |formats|
      document[/\&fmt_url_map=([^(\&|$)]*)/, 1].split(/%2C|,/).map{ |s| s.split(/%7C|\|/) }.map {|key, value| [key.to_i, value] }.select{ |key, value| Video::FORMATS.include?(key) }.each do |key, value|
        formats[key] = CGI::unescape(value).gsub(/\\\//, '/')
      end
    end
  end
  
  def self.by_identifier(identifier)
    Video.new Cache[identifier]
  end
  
  def enclosure
    Video::Enclosure.new(self.identifier, self.url)
  end
  
  def url
    self.formats[Video::FORMATS.find { |key| self.formats.include?(key) }]
  end
end