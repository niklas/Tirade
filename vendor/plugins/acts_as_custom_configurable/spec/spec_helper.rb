#require "rubygems"
require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'init'

#$:.unshift File.dirname(__FILE__) + "/../lib"
#require File.dirname(__FILE__) + "/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table(:houses) do |t|
    t.string :label
    t.text :options
    t.text :defined_options
  end
  create_table(:rooms) do |t|
    t.string :label
    t.text :options
    t.integer :house_id
  end
end

class House < ActiveRecord::Base
  has_many :rooms
  acts_as_custom_configurable :using => :options
end

class Room < ActiveRecord::Base
  belongs_to :house
  acts_as_custom_configurable :using => :options, :defined_by => :house
end

