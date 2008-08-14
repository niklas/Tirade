require File.dirname(__FILE__) + '/../spec_helper'

class Thingy < ActiveRecord::Base
  acts_as_rampant :fields => :name
end

describe Thingy do
  before(:all) do
    setup_db
  end
  after(:all) do
    teardown_db
  end
  describe "that acts as rampant" do
    before(:each) do
      @class = Thingy
      @rampanted = @class.new
    end
    it "should be an ActiveRecord Model" do
      @class.should < ActiveRecord::Base
    end

    it "should know how to generate tags" do
      @rampanted.should respond_to(:generated_auto_tags)
    end

    it "should remember the fields to auto tag" do
      @class.auto_tag_fields.should include(:name)
    end
  end
end
