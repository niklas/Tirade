require File.dirname(__FILE__) + '/../../spec_helper'

describe "/public/index" do
  before(:each) do
    render 'public/index'
  end
end
