require 'rss'
require 'rss/itunes'
require 'cache'

class FeedController < ApplicationController
  
  caches_action :index, :expires_in => 5.minutes
  
  def new
    
  end
  
  def show
    redirect_to Video.new("http://www.youtube.com/watch?v=#{ params[:identifier] }").url
  end
  
  def index
    url = "http://gdata.youtube.com/feeds/base/users/#{ params[:username] }/uploads?alt=rss&v=2&orderby=published"
    @youtube_feed = Feedzirra::Feed.fetch_and_parse(url)
    Rails.logger.info("Found #{ @youtube_feed.entries.count } entries.")
    @youtube_feed.entries.each do |entry|    
      entry.summary = Nokogiri::HTML(entry.summary)
    end
  end
end