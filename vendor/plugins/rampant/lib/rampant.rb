module Rampant
  def self.included(base)
    base.class_eval { extend SingletonMethods }
  end
  module SingletonMethods
    # Available options
    # * :fields
    # 
    # == :fields
    #
    # specifies the fields to use for auto tagging. These should return Strings or should be easy
    # converted into Strings. Ids make no sense.
    #
    def acts_as_rampant(options={})
      class_eval do
        include InstanceMethods
        extend ClassMethods
        cattr_accessor :auto_tag_fields
      end


      # Setup the fields
      fields = [options[:fields]].flatten.compact
      raise NoFieldsSpecified, "Please sepcify fields for auto tagging", caller if fields.empty?
      self.auto_tag_fields = fields

    end
  end
  module ClassMethods
  end
  module InstanceMethods
    def generated_auto_tags
      tag_content = []
      self.class.auto_tags_includes.each do |caller_id|
        unless self.respond_to?(caller_id)
          raise NoMethodError, "Cannot use #{caller_id} for auto_tags because the object has none.", caller
        else
          tag_content << self.send(caller_id).to_s
        end
      end
      AutoTags::AutoTagsGeneration.generate_tags(tag_content.join(' '))
    end
  end

  class NoFieldsSpecified < ArgumentError; end
end
