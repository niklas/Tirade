module Rampant
  def self.included(base)
    base.class_eval { extend SingletonMethods }
  end
  module SingletonMethods
    def acts_as_rampant(options={})
      class_eval do
        include InstanceMethods
        extend ClassMethods
      end
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
end
