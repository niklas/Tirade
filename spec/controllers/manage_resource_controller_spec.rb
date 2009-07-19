require File.dirname(__FILE__) + '/../spec_helper'

describe ManageResourceController::Base do
  it "should inherit from ResourceController::Base" do
    controller.should be_a(ResourceController::Base)
  end
end


