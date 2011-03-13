require 'rss'
require 'rss/itunes'
require 'cache'

class VideosController < ApplicationController
  
  caches_action :index, :expires_in => 5.minutes
  
  def new
  end
  
  def show
    redirect_to Video.by_identifier(params[:identifier]).url
  end
  
  def index
    return redirect_to(root_path) if params[:name].blank?
    
    if request.post?
      request = EventMachine::HttpRequest.new("http://www.youtube.com/user/#{ params[:name ]}").head
      
      if request.response_header.status == 200
        return redirect_to(videos_url :protocol => 'itpc', :name => params[:name])
      end
      
      return render(:text => "The user '#{ params[:name ]}' does not exist", :status => 400)
    end
    
    request = EventMachine::HttpRequest.new("http://gdata.youtube.com/feeds/base/users/#{ params[:name] }/uploads?alt=rss&v=2&orderby=published").get
    @youtube_feed = Feedzirra::Feed.parse(request.response)
    @videos = {}
    @youtube_feed.entries.each do |entry|
      entry.summary = Nokogiri::HTML(entry.summary)
      entry.published = DateTime.parse(entry.published)
    end
    Rails.logger.info("Found #{ @youtube_feed.entries.count } entries.")
  end
end