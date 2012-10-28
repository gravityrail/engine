module Locomotive
  module Liquid
    module Tags
      # embed a video
      class Video < ::Liquid::Tag
        Syntax = /(#{::Liquid::Expression}+)?/
        
        def initialize(tag_name, markup, tokens, context)
          if (markup =~ Syntax) && $1
            video_id = $1.gsub(/"|'/, '') # trim quotes
            @source = ::Locomotive::Video.find(video_id)
            unless @source
              raise ::Liquid::SyntaxError.new("Video not found for id '#{video_id}'") 
            end
          else
            raise ::Liquid::SyntaxError.new("Syntax Error in 'video' - Valid syntax: video <'videoid'|video> <options>")
          end
        end
        
        def render(context)
          render_erb(context, 
             'locomotive/videos/inline.html',
             :video => @source,
             :registers => context.registers)
        end
        
        def render_erb(context, file_name, locals = {})
          context.registers[:controller].send(:render_to_string, :partial => file_name, :locals => locals)
        end
        
        ::Liquid::Template.register_tag('video', Video)
      end
    end
  end
end