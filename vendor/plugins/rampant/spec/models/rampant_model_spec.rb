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
      @rampanted = @class.new :name => "Homer Simpson's Villa"
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

    it "should know about machinetags" do
      @rampanted.should respond_to(:machinetag_list)
      @rampanted.should respond_to(:machinetag_list=)
      @class.should respond_to(:find_machinetagged_with)
      @class.should respond_to(:find_machinetagged_with_by_user)
    end

    describe "its auto tags" do
      before(:each) do
        @auto_tags = @rampanted.generated_auto_tags
      end

      it "should generate auto tags" do
        @auto_tags.should_not be_empty
      end

      it "should include homer" do
        @auto_tags.collect(&:full_name).should include(%[auto:ca="homer simpson"])
      end
    end

    describe "applying some machinetags and saving" do
      before(:each) do
        @given_tagstring = %[geo:home="Gulf of Youtube",fluid:wet=water]
        @mtags = [ 
          Machinetag.new(:namespace => 'geo',:key => 'home',:value => "Gulf of Youtube"),
          Machinetag.new(:namespace => 'fluid', :key => 'wet', :value => "water")  ,
        ]
        @rampanted.machinetag_list = @given_tagstring
        #@saving = lambda { @rampanted.save }
        @rampanted.save
      end

      # WORKS but too much load for the poor Yahoo guys
      #it "should parse the given string" do
      #  Machinetag.should_receive(:new_from_string).with(@given_tagstring).and_return(@mtags)
      #  @saving.call
      #end

      #it "should update machinetags" do
      #  @rampanted.should_receive(:update_machinetags).and_return(true)
      #  @saving.call
      #end

      it "should leave 2 Machinetags" do
        Machinetag.should have_at_least(2).records
      end

      it "should leave 2 Machinetaggings" do
        Machinetagging.should have_at_least(2).records
      end

      it "should return the same machinetags" do
        @rampanted.machinetag_list.should include(%[geo:home="gulf of youtube"])
        @rampanted.machinetag_list.should include(%[fluid:wet=water])
      end

      it "should still have the auto:ca tags" do
        @rampanted.machinetag_list.should include(%[auto:ca="homer simpson"])
      end
    end
  end
end
