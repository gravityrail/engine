module Locomotive
  class Video
    include Locomotive::Mongoid::Document
    field :processed, :type => Boolean, :default => false
    field :zencoder_output_id
    belongs_to :site, :class_name => 'Locomotive::Site'
    index :site_id
    mount_uploader :attachment, Locomotive::VideoUploader
  end
end