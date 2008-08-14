class Machinetag < ActiveRecord::Base
  has_many :machinetaggings

  # Parse a text string into an array of tokens for use as machinetags
  def self.parse(list)
    machinetag_names = []
    
    return machinetag_names if list.blank?
    
    # first, pull out the quoted machinetags
    list.gsub!(/\"(.*?)\"\s*/) { machinetag_names << $1; "" }
    
    # then, replace all commas with a space
    list.gsub!(/,/, " ")
    
    # then, get whatever is left
    machinetag_names.concat(list.split(/\s/))
    
    # delete any blank machinetag names
    machinetag_names = machinetag_names.delete_if { |t| t.empty? }
    
    # downcase all machinetags
    machinetag_names = machinetag_names.map! { |t| t.downcase }
    
    # remove duplicates
    machinetag_names = machinetag_names.uniq
    
    return machinetag_names
  end
  
  # Machinetag a machinetaggable with this machinetag, optionally add user to add owner to machinetagging
  def machinetag(machinetaggable, user_id = nil)
    machinetaggings.create :machinetaggable => machinetaggable, :user_id => user_id
    machinetaggings.reset
    @machinetagged = nil
  end
  
  # A list of all the objects machinetagged with this machinetag
  def machinetagged
    @machinetagged ||= machinetaggings.collect(&:machinetaggable)
  end
  
  # Compare machinetags by name
  def ==(comparison_object)
    super || name == comparison_object.to_s
  end
  
  # Return the machinetag's name
  def to_s
    name
  end
  
  validates_presence_of :name
end