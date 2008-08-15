class Machinetag < ActiveRecord::Base
  has_many :machinetaggings

  FullNameRegexp = /\A([a-z]\w+):([a-z]\w+)=['"]?(.+?)['"]?\Z/x
  # TODO this would be MUCH cooler (and stricter), but I'm doing something wrong
  #FullNameRegexp = /
  #                  (?:\A(\w+):(\w+)="(.+?)"\Z) | 
  #                  (?:\A(\w+):(\w+)='(.+?)'\Z) |
  #                  (?:\A(\w+):(\w+)=(.+)\Z)
  #                 /x

  validates_format_of :full_name, :with => FullNameRegexp, :allow_blank => true
  validates_format_of :namespace, :with => /\w+/
  validates_format_of :key, :with => /\w+/
  validates_format_of :value, :with => /[\w\s]+/

  def full_name
    if value =~ /\s+/
      %Q[#{namespace}:#{key}="#{value}"]
    else
      %Q[#{namespace}:#{key}=#{value}]
    end
  end

  def full_name=(new_full_name)
    if match = FullNameRegexp.match(new_full_name)
      self.namespace = match[1]
      self.key = match[2]
      self.value = match[3]
    else
      self.errors.add(:full_name, "is not a valid machine tag string")
    end
  end
  alias_method :fullname, :full_name
  alias_method :fullname=, :full_name=

  # We want only downcased strings
  [:namespace,:key,:value].each do |field|
    define_method "#{field}=" do |rval|
      self[field] = rval.downcase unless rval.blank?
    end
  end

  def self.find_or_create_by_full_name(full_name)
    t = new :full_name => full_name
    find_or_create_by_namespace_and_key_and_value(t.namespace, t.key, t.value)
  end

  def self.new_from_string(stringed)
    # FIXME this forbids commas in the value
    list = stringed.split(/,/)
    tags = []
    list.each do |name|
      tag = new :full_name => name
      tags << tag if tag.valid?
    end
    tags
  end

  # Returns conditions array that can be used in ActiveRecord:Base.find or similar
  # TODO use a named_scope
  # TODO take options to ie. ignore namespaces
  def self.conditions_from_string(string, opts={})
    new_from_string(string).collect do |tag|
      tag.to_condition(opts)
    end.join(' OR ')
  end

  def to_condition(opts={})
    t = self.class.table_name
    sanitize_sql(["(#{t}.namespace = ? AND #{t}.key = ? AND #{t}.value = ?)", namespace, key, value])
  end
  
  # apply a machinetaggable with this machinetag, optionally add user to add owner to machinetagging
  def apply_to!(machinetaggable, user_id = nil)
    save if new_record?
    machinetaggings.create :machinetaggable => machinetaggable, :user_id => user_id
    machinetaggings.reset
    @machinetagged = nil
  end
  
  # A list of all the objects machinetagged with this machinetag
  def machinetagged
    @machinetagged ||= machinetaggings.collect(&:machinetaggable)
  end
  
  # Compare machinetags by name
  def ==(other)
    super || self.full_name == other.full_name
  end
  
  # Return the machinetag's name
  def to_s
    full_name
  end
  
end
