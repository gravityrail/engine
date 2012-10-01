require 'youtube_it'
module Locomotive
  class YoutubeAccount < RemoteAccount
    include Locomotive::Mongoid::Document
    field :username
    field :password
    
    validates_presence_of :username, :password
    
    validate :account_valid
    def account_valid
      begin
        user = client.current_user
      rescue AuthenticationError => e
        errors.add(:username, "Bad username / password")
        return false
      end
      return true
    end
    
    def client
      YouTubeIt::Client.new(:username => self.username, :password => self.password, :dev_key => YOUTUBE_GDATA_KEY)
    end
  end
end