require 'open-uri'

class Video
  class Enclosure
    attr_reader :identifier, :url, :content_type, :length
    
    def initialize(identifier, url)
      request = EventMachine::HttpRequest.new(url).head

      @url = url
      @identifier = identifier
      @content_type = request.response_header['CONTENT_TYPE']
      @length = request.response_header.content_length
    end
  end
  
  FORMATS = [
    22, # => 'MP4 720p (HD)',
    18, # => 'MP4 360p',
    37, # => 'MP4 1080p (HD)',
    38, # => 'MP4 Original (HD)',
  ]
  
  attr_reader :url, :identifier, :ticket, :formats
  # thin -D
  def initialize(url)
    request = EventMachine::HttpRequest.new(url).get
    response = request.response
    
    @url = url
    
    puts @url

    @identifier = response[/video_id=([-_a-zA-Z0-9]*)/, 1]
    
    raise 'no identifier' if @identifier.blank?
    
    Cache[@identifier] = @url
    
    # volatile
    @formats = {}.tap do |formats|
      response[/fmt_url_map=([-_%.a-zA-Z0-9]*)/, 1].split(/%2C|,/).map{ |s| s.split(/%7C|\|/) }.map {|key, value| [key.to_i, value] }.select{ |key, value| Video::FORMATS.include?(key) }.each do |key, value|
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