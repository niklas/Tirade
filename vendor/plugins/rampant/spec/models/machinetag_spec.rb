require File.dirname(__FILE__) + '/../spec_helper'

describe Machinetag do
  describe "parsing a string with simple names and predicates" do
    before(:each) do
      @string = %q[tom="jerry",mickey="mouse"]
      @mtags = Machinetag.parse @string
    end
    it "should recognize the names" do
      @mtags.should include("tom=")
      @mtags.should include("mickey=")
    end

    it "should recognize the predicates" do
      @mtags.should include("jerry")
      @mtags.should include("mouse")
    end
  end
end
