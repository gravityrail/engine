module Locomotive
  class Video
    #include Rails.application.routes.url_helpers
    
    Format = Struct.new(:name, :width, :height, :quality)
    
    FORMATS = [
      Format.new(:standard, 640, 480, 3),
      Format.new(:mobile, 320, 240, 2)
    ]
    
    include Locomotive::Mongoid::Document
    field :file_name
    field :title
    field :description
    field :copyright
    field :original_url
    field :standard_url
    field :standard_zencoder_output_id
    field :standard_processed, :type => Boolean, :default => false
    field :mobile_url
    field :mobile_zencoder_output_id
    field :mobile_processed, :type => Boolean, :default => false
    
    belongs_to :site, :class_name => 'Locomotive::Site'
    index :site_id
    
    scope :processed, where(:standard_processed => true, :mobile_processed => true)
    scope :processing, any_of({:standard_processed => false}, {:mobile_processed => false})
    
    def processed!(format)
      self.send("#{format}_processed=", true)
      self.save(:validate => false)
    end
    
    before_create :set_title_from_file_name
    def set_title_from_file_name
      self.title ||= self.file_name
    end
    
    after_create :zencode
    def zencode
      return true unless self.original_url
      
      input = original_url.gsub('http://s3.amazonaws.com/', 's3://') # url format: s3://bucket/path/to/file.avi
      base_url = input.gsub(/[^\/]*$/, '') # trim non-path trailing chars, i.e. filename

      # set up the default transcoded URLs for each format
      FORMATS.each {|format| self.send(:"#{format.name}_url=", original_url.gsub(/[^\/]+$/, "#{format.name}.mp4"))}
      
      # create the zencoder job
      zencoder_response = Zencoder::Job.create({
        :input => input,
        :output => FORMATS.map {|format| zencode_output_for(format, base_url)}
      })

      Rails.logger.warn zencoder_response.inspect

      # if we don't hack the dev domain in zencode_output_for, we get something like this:
      # {"errors"=>["The notification url (http://www.transitplatform.dev/zencoder-callback) has an invalid top-level domain: dev", "The notification url (http://www.transitplatform.dev/zencoder-callback) has an invalid top-level domain: dev"]}
      
      # set the output ID for each format
      zencoder_response.body["outputs"].each do |output|
        self.send(:"#{output["label"]}_zencoder_output_id=", output["id"])
        self.send(:"#{output["label"]}_processed=", false)
      end
      
      self.save(:validate => false)
    end
    
    def update_from_zencoder
      FORMATS.each do |format|
        progress = Zencoder::Output.progress(self.send(:"#{format.name}_zencoder_output_id"))
        if progress.body['state'] == 'finished'
          self.send(:"#{format.name}_processed=", true)
          self.save
        end
      end
    end
    
    private
      def zencode_output_for(format, base_url)
        {
          :base_url => base_url,
          :filename => "#{format.name}.mp4",          
          :label => format.name,
          :notifications => [Rails.application.routes.url_helpers.zencoder_callback_url(:host => self.site.full_subdomain.gsub('.dev', '.com'), :protocol => 'http')],
          # defaults
          # :video_codec => "h264",
          # :audio_codec => "aac",
          :quality => format.quality,
          :width => format.width,
          :height => format.height,
          :format => "mp4",
          :aspect_mode => "preserve",
          :public => 1
        }
      end
  end
end