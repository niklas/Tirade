require File.dirname(__FILE__) + '/../spec_helper'

describe ManageResourceController do
  it "should inherit from ResourceController::Base" do
    controller.should be_a(ResourceController::Base)
  end
end


class ThingiesController < ManageResourceController; end
ActionController::Routing::Routes.draw do |map|
  map.resources :thingies
end

