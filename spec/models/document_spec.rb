require File.dirname(__FILE__) + '/../spec_helper'

describe Document do
  it "should act as content" do
    Document.should be_acts_as(:content)
  end

  it "should act as slugged" do
    Document.should be_acts_as(:slugged)
  end
end
