class Part < ActiveRecord::Base
  validates_length_of :preferred_types, :minimum => 1, :message => 'are not enough. Please select at least one.'
  def preferred_types
    read_attribute(:preferred_types) || []
  end

  def preferred_types_names
    preferred_types.join(', ')
  end


  # FIXME dynamicx, reusable!
  def self.valid_content_types
    Rendering.valid_content_types
  end

  def set_default_preferred_types
    self.preferred_types = ['Document'] if preferred_types.empty?
  end
  before_validation :set_default_preferred_types

  def fake_content
    (preferred_types.andand.first || "Document").constantize.sample
  end

end

