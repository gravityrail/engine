module Locomotive
  class RemoteAccount
    include Locomotive::Mongoid::Document
    field :name
    
    belongs_to :site, :class_name => 'Locomotive::Site'
    index :site_id
    
    scope :youtube, where(:_type => 'Locomotive::YoutubeAccount')
    scope :vimeo, where(:_type => 'Locomotive::VimeoAccount')
    
    validates_presence_of :name
  end
end