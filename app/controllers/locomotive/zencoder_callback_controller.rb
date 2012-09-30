module Locomotive
  class ZencoderCallbackController < ApplicationController
 
    skip_before_filter :verify_authenticity_token
 
    def create
      zencoder_response = ''
      sanitized_params = sanitize_params(params)
      sanitized_params.each do |key, value|
        zencoder_response = key.gsub('\"', '"')
      end
 
      json = JSON.parse(zencoder_response)
      
      Rails.logger.warn "parsing zencoder response:"
      Rails.logger.warn json.inspect
      
      output_id = json["output"]["id"]
      job_state = json["output"]["state"]
      format = json["output"]["label"].to_sym
      
      
 
      video = Locomotive::Video.find(:"#{format}_zencoder_output_id" => output_id)
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
end