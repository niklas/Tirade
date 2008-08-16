require_dependency 'acts_as_machinetaggable'
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

        extend ActiveRecord::Acts::Machinetaggable::SingletonMethods          
        include ActiveRecord::Acts::Machinetaggable::InstanceMethods
        has_many :machinetaggings, :as => :machinetaggable, :dependent => :destroy, :include => :machinetag
        has_many :machinetags, :through => :machinetaggings, :order => 'namespace ASC,key ASC'
          

        before_save :determine_content_freshness
        after_save :generate_auto_tags_if_fresh
        after_save :update_machinetags
      end


      # Setup the fields
      fields = [options[:fields]].flatten.compact
      raise NoFieldsSpecified, "Please specify fields for auto tagging", caller if fields.empty?
      self.auto_tag_fields = fields

    end
  end
  module ClassMethods
  end
  module InstanceMethods
    def generated_auto_tokens
      tag_content = []
      self.class.auto_tag_fields.each do |caller_id|
        unless self.respond_to?(caller_id)
          raise NoMethodError, "Cannot use #{caller_id} for auto_tags because the object has none.", caller
        else
          tag_content << self.send(caller_id).to_s
        end
      end
      AutoTags::AutoTagsGeneration.generate_tags(tag_content.join(' '))
    end

    def generated_auto_tags
      generated_auto_tokens.collect do |token|
        Machinetag.new :namespace => 'auto', :key => 'ca', :value => token
      end
    end

    # check (before_safe) if any fields for auto_tags have changed, apply them after_save
    def determine_content_freshness
      @auto_tags_need_update = self.class.auto_tag_fields.any? {|field| self.changed.include? field.to_s }
      true
    end

    def generate_auto_tags_if_fresh
      if @auto_tags_need_update
        Machinetag.transaction do
          machinetaggings.auto.destroy_all
          generated_auto_tags.each do |tag|
            tag.apply_to!(self)
          end
          machinetags.reset
          machinetaggings.reset
          @auto_tags_need_update = false
        end
      end
      true
    end
  end

  class NoFieldsSpecified < ArgumentError; end
end
