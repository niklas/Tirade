require File.dirname(__FILE__) + '/../spec_helper'

                    # \A(\w+):(\w+)=['"]?(.+?)['"]?\Z
describe Machinetag do
  describe "by full_name without quotes" do
    before(:each) do
      @full_name = 'geo:long=23.5'
      @mtag = Machinetag.new :fullname => @full_name
    end
    it "should not add error" do
      @mtag.should have(:no).errors_on(:full_name)
    end
    it "should be valid" do
      @mtag.should be_valid
    end
    it "should parse it" do
      @mtag.namespace.should == 'geo'
      @mtag.key.should == 'long'
      @mtag.value.should == '23.5'
    end
    it "should re-construct its fullname" do
      @mtag.full_name.should == @full_name
    end
  end

  describe "by full_name with quotes" do
    before(:each) do
      @full_name = 'favourite:beer="Erdinger Weißbier"'
      @mtag = Machinetag.new :fullname => @full_name
    end
    it "should not add error" do
      @mtag.should have(:no).errors_on(:full_name)
    end
    it "should be valid" do
      @mtag.should be_valid
    end
    it "should parse it" do
      @mtag.namespace.should == 'favourite'
      @mtag.key.should == 'beer'
      @mtag.value.should == 'Erdinger Weißbier'.downcase
    end
    it "should re-construct its fullname" do
      @mtag.full_name.should == @full_name.downcase
    end
  end

  describe "by full_name with bad namespace/key" do
    before(:each) do
      @full_name = 'invalidnamespace="is not valid"'
      @mtag = Machinetag.new :fullname => @full_name
    end
    it "should have any error" do
      @mtag.should have_at_least(1).error
    end
    it "should add error on full_name" do
      @mtag.should have(1).errors_on(:full_name)
    end
    it "should not be valid" do
      @mtag.should_not be_valid
    end
  end

  describe "by full_name without equal sign" do
    before(:each) do
      @full_name = 'invalidnamespace:"is not valid"'
      @mtag = Machinetag.new :fullname => @full_name
    end
    it "should have any error" do
      @mtag.should have_at_least(1).error
    end
    it "should add error on full_name" do
      @mtag.should have(1).errors_on(:full_name)
    end
    it "should not be valid" do
      @mtag.should_not be_valid
    end
  end

  describe "parsing a string with multiple tags" do
    before(:each) do
      @string = %q[tom:name=jerry,mickey:name="mr. mouse"]
      @mtags = Machinetag.new_from_string @string
      @mtags_names = @mtags.collect(&:full_name)
    end
    it "should recognize 2 Machinetags" do
      @mtags.should have_at_least(2).records
    end
    it "should have only valid Machinetags" do
      @mtags.each do |mtag|
        mtag.should be_valid
      end
    end
    it "should re-construct the full_names" do
      @mtags_names.should include(%q[tom:name=jerry])
      @mtags_names.should include(%q[mickey:name="mr. mouse"])
    end
  end
end
