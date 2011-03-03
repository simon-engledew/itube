require 'rss'
require 'rss/itunes'
require 'cache'

class FeedController < ApplicationController
  
  caches_action :index, :expires_in => 5.minutes
  
  def new
  end
  
  def show
    redirect_to Video.by_identifier(params[:identifier]).url
  end
  
  def index
    request = EventMachine::HttpRequest.new("http://gdata.youtube.com/feeds/base/users/#{ params[:username] }/uploads?alt=rss&v=2&orderby=published").get
    @youtube_feed = Feedzirra::Feed.parse(request.response)
    @videos = {}
    @youtube_feed.entries.each do |entry|
      entry.summary = Nokogiri::HTML(entry.summary)
      entry.published = DateTime.parse(entry.published)
    end
    Rails.logger.info("Found #{ @youtube_feed.entries.count } entries.")
  end
end