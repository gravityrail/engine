module Locomotive
  class AnalyticsController < BaseController

    sections 'analytics', 'index'

    skip_load_and_authorize_resource

    load_and_authorize_resource :class => 'Site'

    helper 'Locomotive::Sites'

    respond_to :json, :only => :update

    def index
      @content_for_title = "Analytics"
      @site = current_site
    end

  end
end
