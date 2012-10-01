require 'vimeo'

module Locomotive
  class VimeoAccount < RemoteAccount
    include Locomotive::Mongoid::Document
    field :token
    field :secret
    
    def channels
      channel = Vimeo::Advanced::Channel.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET, :token => self.token, :secret => self.secret)
      channel.get_all
    end
    
    def client
      Vimeo::Advanced::Base.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET, :token => self.token, :secret => self.secret)
    end
    
    def self.client
      Vimeo::Advanced::Base.new(VIMEO_CONSUMER_KEY, VIMEO_CONSUMER_SECRET)
    end
  end
end