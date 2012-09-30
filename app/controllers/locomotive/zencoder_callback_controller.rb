class Locomotive::ZencoderCallbackController < ApplicationController 
  skip_before_filter :verify_authenticity_token

  def create
    # Rails.logger.warn params.inspect
    # zencoder_response = ''
    # sanitized_params = sanitize_params(params)
    # sanitized_params.each do |key, value|
    #   zencoder_response = key.gsub('\"', '"')
    # end
    # 
    # unless zencoder_response
    #   render :text => "Invalid zencoder callback: #{params.inspect}", :status => 403
    #   return
    # end
    # 
    # json = nil
    # begin
    #   json = JSON.parse(zencoder_response)
    # rescue JSON::ParserError => e
    #   render :text => "Invalid JSON format, #{e.message}: #{params.inspect}", :status => 403
    #   return
    # end
    # Rails.logger.warn "parsing zencoder response:"
    Rails.logger.warn params.inspect
    
    output_id = params["output"]["id"]
    job_state = params["output"]["state"]
    format = params["output"]["label"].to_sym
    
    video = Locomotive::Video.where(:"#{format}_zencoder_output_id" => output_id).first
    if job_state == "finished" && video
      video.processed!(format)
    end

    render :nothing => true
  end

  private

  def sanitize_params(params)
    params.delete(:action)
    params.delete(:controller)
    params
  end

end