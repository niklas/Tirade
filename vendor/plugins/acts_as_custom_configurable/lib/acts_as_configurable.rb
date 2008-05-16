# = ActsAsConfigurable
# 
# This act provides the ability to specify settings on a model class similarly
# to the way columns are defined in migrations, including default values.
# 
# == Usage
# 
# You can use this plugin by declaring acts_as_configurable inside any
# ActiveRecord model.
# 
# Example:
# 
#   class Blog < ActiveRecord::Base
#     acts_as_configurable do |c|
#       c.string :title, :default => "My Blog"
#       c.integer :number_of_frontpage_articles, :default => 10
#       c.boolean :enable_akismet, :default => false
#     end
#   end
# 
# This will define instance methods on Blog for each setting, with the
# specified default values.  These attributes can be used in mass-assignment,
# validations, and pretty much anywhere else you'd use a normal database column.
module ActsAsConfigurable
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
  end

  class SettingsProxy
    # Initializes a new SettingsProxy and passes it to a block, if given.
    def initialize # :nodoc:
      @items = []
      yield(self) if block_given?
    end

    # Setting items defined by this proxy.
    attr_reader :items

    # Creates a string setting with the given +name+.  Any values passed
    # into this setting will automatically be converted into strings.
    # 
    # Example:
    #   acts_as_configurable do |c|
    #     c.string :title, :default => "My Title"
    #   end
    # 
    # Options:
    #   [default]  Default value.
    def string(name, options = {})
      items << StringItem.new(name, options)
    end

    # Creates an integer setting with the given +name+.  Any values passed
    # into this setting will automatically be converted into integers.
    # 
    # Example:
    #   acts_as_configurable do |c|
    #     c.integer :number_of_articles_to_show_on_front_page, :default => 20
    #   end
    # 
    # Options:
    #   [default]  Default value.
    def integer(name, options = {})
      items << IntegerItem.new(name, options)
    end

    # Creates a boolean setting with the given +name+.  Any values passed
    # into this setting will automatically be converted into either true
    # or false.
    # 
    # Example:
    #   acts_as_configurable do |c|
    #     c.boolean :enable_spam_filtering, :default => false
    #   end
    # 
    # Options:
    #   [default]  Default value.
    def boolean(name, options = {})
      items << BooleanItem.new(name, options)
    end

    # Creates an object setting with the given +name+.  Any values passed
    # into this setting will be passed straight through.  This only
    # supports objects that can be serialized by YAML.
    # 
    # Example:
    #   acts_as_configurable do |c|
    #     c.object :ip_address, :default => IPAddr.new("127.0.0.1")
    #   end
    # 
    # Options:
    #   [default]  Default value.
    def object(name, options = {})
      items << ObjectItem.new(name, options)
    end
  end

  class ObjectItem # :nodoc:
    def initialize(name, options)
      @name = name.to_s
      @default = options[:default]
    end
    def type_to_s
      self.class.to_s.underscore.split('_').first
    end
    attr_reader :name, :default

    # No conversion is performed for objects.  Simply returns +value+.
    def typecast(value)
      value
    end
  end

  class StringItem < ObjectItem # :nodoc:
    # Converts +value+ to a string by calling #to_s.
    def typecast(value)
      value.to_s
    end
  end

  class IntegerItem < ObjectItem # :nodoc:
    # Converts +value+ to an integer by calling #to_i.
    def typecast(value)
      if value.respond_to?(:to_i)
        value.to_i
      else
        value ? 1 : 0
      end
    end
  end

  class BooleanItem < ObjectItem # :nodoc:
    # Values that are considered false.  Any other values are considered true.
    FALSE_VALUES = [false, "false", "f", 0, "0", nil]

    # Converts +value+ to a boolean by checking to see if it's one
    # of FALSE_VALUES.
    def typecast(value)
      !FALSE_VALUES.include?(value)
    end
  end

  module ActsMethods # :nodoc:
    private

    def add_setting_accessor(item)
      add_setting_reader(item)
      add_setting_writer(item)
    end

    def add_setting_reader(item)
      define_method(item.name) do
        column = send(acts_as_configurable_options[:using]) || send("#{acts_as_configurable_options[:using]}=", Hash.new)
        column.has_key?(item.name) ? column[item.name] : item.default
      end
      define_method("#{item.name}?") { !send(item.name).blank? }
    end

    def add_setting_writer(item)
      define_method("#{item.name}=") do |value|
        column = send(acts_as_configurable_options[:using]) || send("#{acts_as_configurable_options[:using]}=", Hash.new)
        column[item.name] = item.typecast(value)
      end
    end
  end

  module InstanceMethods
    def options
      #return @options if @options
      @options = OptionsProxy.new(self)
    end
    def options=(new_options)
      options.each_item do |name,item|
        new_val = new_options[name] || new_options[name.to_sym]
        options[name] = new_val
      end
    end
  end

  class OptionsProxy
    attr_reader :items
    def initialize(record)
      @record = record
      @definitions = record.send(conf[:defined_in])

      @items = SettingsProxy.new do |c|
        @definitions.each do |field_name, defi|
          c.send(defi.first,field_name, :default => defi[1])
        end unless @definitions.blank?
      end.items.inject({}) {|h,i| h[i.name] = i; h}.with_indifferent_access
    end

    def values
      f = conf[:using]
      @record.write_attribute(f, {}) unless @record.read_attribute(f)
      @record.read_attribute(f)
    end

    def to_hash
      values
    end

    def to_yaml
      to_hash.to_yaml
    end

    def each_item
      @items.each do |name,item|
        yield name, item
      end
    end

    def values_from_association
      if assoc = conf[:defined_by] 
        foreign = @record.send(assoc)
        foreign.send(foreign.class.acts_as_custom_configurable_options[:using]).values
      else
        nil
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^(.*)=$/
        self[$1] = args.first
      elsif method.to_s =~ /^(.*)\?$/
        self[$1].blank?
      else
        self[method.to_s]
      end
    end

    def []=(n, arg)
      name = n.to_s
      if item = items[name]
        if arg.blank?
          values.delete(name)
        else
          values[name] = item.typecast arg
        end
      else
        raise NoMethodError, "no setter for '#{name}' found"
      end
    end

    def [](n)
      name = n.to_s
      if item = items[name]
        if values.has_key?(name)
          values[name]
        elsif (va = values_from_association) && va.has_key?(name)
          va[name]
        else
          item.default
        end
      else
        raise NoMethodError, "no getter for '#{name}' found"
      end
    end


    private

    def conf
      @record.class.send(:acts_as_custom_configurable_options)
    end
  end

  module ClassMethods
    # Defines an ActiveRecord class as configurable.  Passes a proxy object into
    # the given block, which is used to declare settings.
    # 
    # Options:
    # [using] The database column to store configuration in.  Defaults to
    #         :settings.  Note that this should be a text column, to ensure
    #         that there's enough room for the entire serialized settings
    #         object to fit in.
    # 
    # Example:
    #   class Blog < ActiveRecord::Base
    #     acts_as_configurable do |c|
    #       c.string :title, :default => "My Blog"
    #       c.integer :number_of_frontpage_articles, :default => 10
    #       c.boolean :enable_akismet, :default => false
    #     end
    #   end
    # 
    # This will define getter, setter, and query methods for each setting:
    # 
    #   blog.title # => "My Blog"
    #   blog.title = "My Custom Blog"
    #   blog.title # => "My Custom Blog"
    # 
    #   blog.enable_akismet? # => false
    #   blog.enable_akismet = true
    #   blog.enable_akismet? # => true
    # 
    # If you would like to use a different database column to store settings in,
    # specify it in the :using option.
    # 
    #   class Blog < ActiveRecord::Base
    #     acts_as_configurable :using => :preferences do |c|
    #       ...
    #     end
    #   end
    # 
    # The above will force ActsAsConfigurable to store settings in the
    # "preferences" column instead of the default "settings" column.
    def acts_as_configurable(options = {}, &block)
      options.symbolize_keys!.reverse_merge!(:using => :settings)
      write_inheritable_hash(:acts_as_configurable_options, options)
      class_inheritable_reader(:acts_as_configurable_options)
      serialize(acts_as_configurable_options[:using], Hash)
      extend(ActsMethods)
      SettingsProxy.new(&block).items.each { |item| add_setting_accessor(item) }
    end

    def acts_as_custom_configurable(options = {})
      options.symbolize_keys!
      if assoc = options[:defined_by]
        delegate (options[:defined_in] || :defined_options), :to => assoc.to_sym
      end
      options.reverse_merge!(:using => :options, :defined_in => :defined_options)
      write_inheritable_hash(:acts_as_custom_configurable_options, options)
      class_inheritable_reader(:acts_as_custom_configurable_options)
      serialize(acts_as_custom_configurable_options[:using], Hash)
      serialize(acts_as_custom_configurable_options[:defined_in], Hash)
      include InstanceMethods
    end
  end
end
