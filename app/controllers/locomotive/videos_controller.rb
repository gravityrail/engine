module Locomotive
  class VideosController < BaseController

    sections 'videos', 'index'

    localized
    
    #load_and_authorize_resource :class => 'Site'
    
    #helper 'Locomotive::Sites'

    #before_filter :back_to_default_site_locale, :only => %w(new create)

    #respond_to    :json, :only => [:show, :create, :update]

    def index
      @videos = current_site.videos
      respond_with(@videos)
    end

    def show
      @video = current_site.videos.find(params[:id])
      respond_with @video
    end

    def new
      @video = current_site.videos.build
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
  end
end