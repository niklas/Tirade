class Part < ActiveRecord::Base
  class UnsupportedContentType < Exception; end

  #validates_length_of :preferred_types, :minimum => 1, :message => 'are not enough. Please select at least one.'
  def preferred_types
    (read_attribute(:preferred_types) || []) - ['none']
  end

  def preferred_types_names
    preferred_types.join(', ')
  end

  def static?
    read_attribute(:preferred_types).andand.include?('none')
  end


  # FIXME dynamicx, reusable!
  def self.valid_content_types
    Tirade::ActiveRecord::Content.classes
  end

  def set_default_preferred_types
    self.preferred_types = ['none'] if preferred_types.empty?
  end
  before_validation :set_default_preferred_types

  def fake_content
    klass_name = (supported_types.andand.first || "Document")
    klass_name.constantize.sample
  end

  def supported_types
    Tirade::ActiveRecord::Content.class_names & preferred_types
  end

  def supported_types_names
    supported_types.join(', ')
  end

  validate :content_type_must_be_supported, :unless => Proc.new { |part| part.preferred_types.blank? }
  def content_type_must_be_supported
    if supported_types.empty?
      errors.add(:preferred_types, "like #{preferred_types_names} not supported, please add to config/application.yml")
    end
  end

end

