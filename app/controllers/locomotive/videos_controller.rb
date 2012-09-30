module Locomotive
  class VideosController < BaseController
    require 'base64'
    require 'openssl'
    
    sections 'videos', 'index'

    localized
    
    #load_and_authorize_resource :class => 'Site'
    
    #helper 'Locomotive::Sites'

    #before_filter :back_to_default_site_locale, :only => %w(new create)

    #respond_to    :json, :only => [:show, :create, :update]

    def index
      @videos = current_site.videos
      @content_for_title = "Videos"
      respond_with(@videos)
    end

    def show
      @video = current_site.videos.find(params[:id])
      @content_for_title = @video.file_name
      respond_with @video
    end

    def new
      @content_for_title = "Upload Video"
      @video = current_site.videos.build
      @bucket_url = bucket_url
      @aws_access_key = aws_access_key
      @key = key
      @acl = acl
      @s3_policy = s3_policy
      @s3_signature = s3_signature
      @upload_path = upload_path
      @policy = policy_doc
      respond_with @video
    end
    
    def create
      @video = current_site.videos.build(params[:video])
      
      if @video.save
        render :nothing => true
      else
        render :nothing => true, :status => 400
      end
      
#      respond_with @video, :location => edit_video_url(@video._id)
    end

    def edit
      @video = current_site.videos.find(params[:id])
      @content_for_title = "Edit #{@video.file_name}"
      respond_with @video
    end

    def update
      @video = current_site.videos.find(params[:id])
      @video.update_attributes(params[:video])
      respond_with @video, :location => edit_video_url(@video._id)
    end

    def destroy
      @video = current_site.videos.find(params[:id])
      @video.destroy
      respond_with @video
    end
    
    private 
      def aws_access_key
        ENV['S3_KEY_ID']
      end
    
      def aws_secret_key
        ENV['S3_SECRET_KEY']
      end
  
      def max_filesize
        20.megabyte
      end
    
      def expiration_date
        24.hours.from_now.utc.strftime('%Y-%m-%dT%H:00:00.000Z')
      end
    
      def acl
        "public-read"
      end
    
      def s3_policy
        Base64.encode64(policy_doc).gsub(/\n|\r/, '')
      end
    
      def upload_path
        "sites/#{current_site.id.to_s}/videos"
      end
      
      def bucket_url
        "http://s3.amazonaws.com/#{bucket}/"
      end
      
      def key
        "#{upload_path}/#{rangen}/${filename}" #${filename}
      end
    
      def rangen
        @rangen ||= rand(36 ** 8).to_s(36)
      end
    
      def policy_doc 
        @policy ||= <<-ENDPOLICY
          {
            'expiration': '#{expiration_date}',
            'conditions': [
              {'bucket': '#{bucket}'},
              ['starts-with', '$key', '#{upload_path}'],
              {'acl': '#{acl}'},
              ['starts-with','$Filename','']
            ]
          }
        ENDPOLICY
      end
      
      def s3_policy
        Base64.encode64(policy_doc).gsub(/\n|\r/, '')
      end

      def s3_signature
        b64_hmac_sha1(aws_secret_key, s3_policy)
      end
      
      def b64_hmac_sha1(aws_secret_key, doc)
        [OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), aws_secret_key, doc)].pack("m").strip
      end
      
      def bucket
        ENV['S3_BUCKET']
      end
    
  end
end