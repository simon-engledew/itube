require 'open-uri'

class Video < ActiveRecord::Base
  # FORMAT_PRIORITIES = [37, 22, 18, 38]
  FORMAT_PRIORITIES = [22, 18]
  FORMAT_LABELS = {
    18 => 'MP4 360p',
    22 => 'MP4 720p (HD)',
    37 => 'MP4 1080p (HD)',
    38 => 'MP4 Original (HD)',
  }
  FORMAT_EXTENSIONS = {
    18 => 'mp4',
    22 => 'mp4',
    37 => 'mp4',
    38 => 'mp4',
  }
  
  attr_reader :identifier, :ticket, :formats
  
  def initialize(url)
    document = Cache.read(url) { Feedzirra::Feed.fetch_raw(url) }

    @identifier = document[/\&video_id=([^(\&|$)]*)/, 1]
    @ticket = document[/\&t=([^(\&|$)]*)/, 1]
    @formats = {}.tap do |formats|
      document[/\&fmt_url_map=([^(\&|$)]*)/, 1].split(/%2C|,/).map{ |s| s.split(/%7C|\|/) }.map {|key, value| [key.to_i, value] }.select{ |key, value| FORMAT_LABELS.include?(key) }.each do |key, value|
        formats[key] = CGI::unescape(value).gsub(/\\\//, '/')
      end
    end
  end
  
  def url
    @formats[FORMAT_PRIORITIES.find { |key| @formats.include?(key) }]
  end
end