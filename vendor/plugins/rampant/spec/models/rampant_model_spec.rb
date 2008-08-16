require File.dirname(__FILE__) + '/../spec_helper'

class Thingy < ActiveRecord::Base
  acts_as_rampant :fields => :name
  validates_uniqueness_of :name
end

describe Thingy do
  before(:all) do
    setup_db
    Machinetag.destroy_all
    Machinetagging.destroy_all
    @class = Thingy
    @rampanted = @class.new :name => "Homer Simpson's Villa"
  end
  after(:all) do
    @rampanted.destroy unless @rampanted.nil?
    teardown_db
  end
  describe "that acts as rampant" do
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

    describe "which got some machinetags applied and saved" do
      before(:each) do
        @given_tagstring = %[geo:home="Gulf of Youtube",fluid:wet=water]
        @mtags = [ 
          Machinetag.new(:namespace => 'geo',:key => 'home',:value => "Gulf of Youtube"),
          Machinetag.new(:namespace => 'fluid', :key => 'wet', :value => "water")  ,
        ]
        @rampanted.machinetag_list = @given_tagstring
        @rampanted.save.should be_true
      end

      it "should leave 3 Machinetags" do
        Machinetag.should have_at_least(3).records
      end

      it "should leave 3 Machinetaggings" do
        Machinetagging.should have_at_least(3).records
      end

      it "should have one auto tag" do
        @rampanted.machinetags.auto.count.should == 1
      end

      it "should not generate more thingies" do
        Thingy.should have(1).record
      end

      it "should have two no-auto tags" do
        @rampanted.machinetags.without_auto.count.should == 2
      end

      it "should return the manual machinetags" do
        @rampanted.machinetag_list.should include(%[geo:home="gulf of youtube"])
        @rampanted.machinetag_list.should include(%[fluid:wet=water])
      end

      #it "should still have the auto:ca tags" do
      #  @rampanted.machinetag_list.should include(%[auto:ca="homer simpson"])
      #end
    end
  end
end
