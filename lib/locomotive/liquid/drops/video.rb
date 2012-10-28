module Locomotive
  module Liquid
    module Drops
      class Video < Base
        delegate :title, :description, :file_name, 
                 :keywords, :category, :copyright,
                 :original_url, 
                 :standard_url, :standard_thumb_url,
                 :mobile_url, :mobile_thumb_url,
                 :to => '_source'
      end
    end
  end
end