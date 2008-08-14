class Machinetag < ActiveRecord::Base
  has_many :machinetaggings

  def full_name
    if value =~ /\s+/
      %Q[#{namespace}:#{key}="#{value}"]
    else
      %Q[#{namespace}:#{key}=#{value}]
    end
  end

  # We want only downcased strings
  [:namespace,:key,:value].each do |field|
    define_method "#{field}=" do |rval|
      self[field] = rval.downcase
    end
  end

  def full_name=(new_full_name)
    if new_full_name =~ /^(\w+):(\w+)="(.+)"$/
      self.namespace =      $1
      self.key =                  $2
      self.value =                      $3
    elsif new_full_name =~ /^(\w+):(\w+)='(.+)'$/
      self.namespace =         $1
      self.key =                     $2
      self.value =                         $3
    elsif new_full_name =~ /^(\w+):(\w+)=(.+)$/
      self.namespace =         $1
      self.key =                     $2
      self.value =                        $3
    else
      errors.add(:full_name, "not a valid")
    end
  end
  alias_method :fullname, :full_name
  alias_method :fullname=, :full_name=

  def self.new_from_string(stringed)
    # FIXME this forbids commas in the value
    list = stringed.split(/,/)
    tags = []
    list.each do |name|
      tag = new :full_name => name
      tags << tag if tag.errors.empty?
    end
    tags
  end

  # Returns conditions array that can be used in ActiveRecord:Base.find or similar
  # TODO use a named_scope
  # TODO take options to ie. ignore namespaces
  def self.conditions_from_string(string, opts={})
    new_from_string(string).collect do |tag|
      tag.to_condition(opts)
    end.join(' AND ')
  end

  def to_condition(opts={})
    sanitize_sql(['(namespace = ? AND key = ? AND value = ?)', namespace, key, value])
  end

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