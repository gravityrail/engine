module Locomotive
  class RemoteAccountsController < BaseController
    sections 'videos', 'syndication'
    
    def index
      @accounts = current_site.remote_accounts
      @content_for_title = "Remote Accounts"
      load_accounts
      respond_with(@accounts)
    end

    def show
      @account = current_site.remote_accounts.find(params[:id])
      @content_for_title = @account.name
      respond_with @account
    end

    def create
      create_youtube if params[:youtube_account]
      create_vimeo if params[:vimeo_account]
    end
    
    def update
      account = current_site.remote_accounts.find(params[:id])
      if account.update_attributes(params[:youtube_account] || params[:vimeo_account])
        load_accounts
        render :action => :index
      else
        flash[:notice] = "Failed to update account"
        load_accounts
        render :action => :index, :status => 400
      end
    end
    
    def destroy
      @account = current_site.remote_accounts.find(params[:id])
      @account.destroy
      flash[:notice] = "Disconnected account"
      redirect_to :action => :index
    end
    
    def callback_vimeo
      client = VimeoAccount.client
      access_token = client.get_access_token(params[:oauth_token], session[:vimeo_oauth_secret], params[:oauth_verifier])
      @vimeo_account = VimeoAccount.new(:site => current_site, :name => session[:vimeo_name], :token => access_token.token, :secret => access_token.secret)
      if @vimeo_account.save
        flash[:notice] = "Connected Vimeo account"
        load_accounts
        render :action => :index
      else
        flash[:alert] = "Could not connect Vimeo account"
        load_accounts
        render :action => :index, :status => 400
      end
    end
    
    private
      def create_youtube
        @youtube_account = Locomotive::YoutubeAccount.new(params[:youtube_account])

        current_site.remote_accounts << @youtube_account

        if current_site.save && @youtube_account.save
          flash[:notice] = "Linked YouTube account"
          redirect_to :action => :index
        else
          flash[:notice] = "Failed to link YouTube account"
          load_accounts
          render :action => :index, :status => 400
        end
      end
      
      def create_vimeo
        
        client = VimeoAccount.client
        session[:vimeo_oauth_secret] = client.get_request_token.secret
        session[:vimeo_name] = params[:vimeo_account][:name]
        redirect_to client.authorize_url
        
        # @vimeo_account = Locomotive::VimeoAccount.new(params[:vimeo_account])
        # 
        #         current_site.remote_accounts << @vimeo_account
        # 
        #         if current_site.save && @vimeo_account.save
        #           flash[:notice] = "Linked Vimeo account"
        #           redirect_to :action => :index
        #         else
        #           flash[:notice] = "Failed to link Vimeo account"
        #           load_accounts
        #           render :action => :index, :status => 400
        #         end
      end
    
      def load_accounts
        @youtube_account ||= current_site.remote_accounts.youtube.first || Locomotive::YoutubeAccount.new(:site => current_site)
        @vimeo_account ||= current_site.remote_accounts.vimeo.first || Locomotive::VimeoAccount.new(:site => current_site)
      end

    # def new
    #       type = params[:account_type]
    #       
    #       @content_for_title = "Create Remote Account"
    #       @video = current_site.videos.build
    #       @bucket_url = bucket_url
    #       @aws_access_key = aws_access_key
    #       @key = key
    #       @acl = acl
    #       @s3_policy = s3_policy
    #       @s3_signature = s3_signature
    #       @upload_path = upload_path
    #       @policy = policy_doc
    #       respond_with @video
    #     end
    #     
    #     def create
    #       @video = current_site.videos.build(params[:video])
    #       
    #       if @video.save
    #         render :nothing => true
    #       else
    #         render :nothing => true, :status => 400
    #       end
    #       
    # #      respond_with @video, :location => edit_video_url(@video._id)
    #     end
    # 
    #     def edit
    #       @video = current_site.videos.find(params[:id])
    #       @content_for_title = "Edit #{@video.title}"
    #       respond_with @video
    #     end
    # 
    #     def update
    #       @video = current_site.videos.find(params[:id])
    #       @video.update_attributes(params[:video])
    #       respond_with @video, :location => edit_video_url(@video._id)
    #     end
    # 
    #     def destroy
    #       @video = current_site.videos.find(params[:id])
    #       @video.destroy
    #       respond_with @video
    #     end
  end
end