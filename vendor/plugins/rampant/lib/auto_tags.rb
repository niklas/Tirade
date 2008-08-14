# Copyright (c) 2008 [Sur http://expressica.com]

require 'net/http'
require 'rexml/document'

module AutoTags #:nodoc
  class AutoTagsGeneration
    cattr_accessor :appid
    
    CONFIG = {
      :default_appid => 'k5rYmAnV34EN0RqBR_dl_PbL.B5mTq2KhEO2t4pVPrdZrjnN.auZtEyk0WxyPoY-',
      :port => 80,
      :host => 'search.yahooapis.com',
      :url => 'http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction'
    }
    
    class << self
      def get_appid
        appid || CONFIG[:default_appid]
      end
      
      # sends the api call to generate the tags.
      def generate_tags(context='')
        return [] if context.blank?
        req = Net::HTTP::Post.new(CONFIG[:url])
        req.set_form_data(:appid => get_appid, :context => context)
        begin
          Net::HTTP.start(CONFIG[:host], CONFIG[:port]) do |http|
            xml = REXML::Document.new(http.request(req).body)
            case xml.elements.to_a.first.fully_expanded_name
            when 'ResultSet'
              tags = []
              xml.elements.to_a.first.get_elements('Result').each{|el| tags << el.text}
              return tags
            when 'Error'
              error_messages = []
              xml.elements.to_a.first.get_elements('Message').each{|el| error_messages << el.text}
              # raise AutoTagsServerError, error_messages.join(" "), caller
              return []
            end
          end
        rescue
          # raise AutoTagsServerError, "auto_tags server connection error", caller
          return []
        end
      end
    end
  end
end
