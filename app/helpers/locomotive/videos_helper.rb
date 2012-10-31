module Locomotive
  module VideosHelper
    def video_duration(video)
      if(video.duration)
        distance_of_time_in_words(Time.now, Time.now + (video.duration/1000).seconds, true)
      else
        'n/a'
      end
    end
  end
end