require File.dirname(__FILE__) + '/../../spec_helper'

describe "Using a missing constant" do
  before( :each ) do
  end
  def reference!
    @constant = Object.const_get @name
  end
  def dereference!(name)
    ActiveSupport::Dependencies.remove_constant name
    ActiveSupport::Dependencies.autoloaded_constants.delete name
  end

  describe "valid class constant", :shared => true do
    it "should not raise NameError" do
      lambda { reference! }.should_not raise_error(NameError)
    end
    it "should not raise RuntimeError" do
      lambda { reference! }.should_not raise_error(RuntimeError)
    end
    it "should be automatically loaded" do
      pending("not added to autoloaded constants")
      ActiveSupport::Dependencies.autoloaded?(@name).should be_true
    end
    it "should be included in ActiveSupport's autoloaded_constants" do
      pending("not added to autoloaded constants")
      ActiveSupport::Dependencies.autoloaded_constants.sort.should include(@name)
    end
    it "should create this constant" do
      reference!
      @constant.should_not be_nil
      @constant.should be_a(Class)
    end
  end

  describe "valid controller constant", :shared => true do
    it_should_behave_like 'valid class constant'
    
    it "should inherit from ApplicationController" do
      reference!
      @constant.should < ApplicationController
    end
  end

  describe "valid resource controller constant", :shared => true do
    it_should_behave_like 'valid controller constant'
    
    it "should inherit from ManageResourceController::Base" do
      reference!
      @constant.should < ManageResourceController::Base
    end
  end

  describe "referencing a controller to manage VeryShyDragons" do
    before( :each ) do
      @name = 'VeryShyDragonsController'
      @model_name = 'VeryShyDragon'
      @model = Object.const_set(@model_name, Class.new(ActiveRecord::Base)) 
      @model.unloadable
      @model.acts_as_content
    end
    after( :each ) do
      dereference!(@name)
      dereference!(@model_name)
    end

    it_should_behave_like 'valid resource controller constant'
    it "should have the correct model" do
      reference!
      @constant.new.send(:model).should == @model
    end
  end

  describe "referencing a controller that does not manage a resource but is loadable from file (PublicController)" do
    before( :each ) do
      @name = 'PublicController'
    end
    it_should_behave_like 'valid controller constant'

    it "should not inherit from ManageResourceController::Base" do
      reference!
      @constant.should_not < ManageResourceController::Base
    end
  end

  describe "referencing a constant to manage resources that is loadable from file (StylesheetsController)" do
    before( :each ) do
      @name = 'StylesheetsController'
    end
    it_should_behave_like 'valid controller constant'

    it "should not inherit from ManageResourceController::Base" do
      reference!
      @constant.should_not < ManageResourceController::Base
    end
  end

  describe "referencing another constant" do
    before( :each ) do
      @name = 'VeryShyDragonsHelperle'
    end
    it "should raise NameError" do
      lambda { reference! }.should raise_error(NameError)
    end
  end

end

