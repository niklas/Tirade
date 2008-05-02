require File.dirname(__FILE__) + '/../spec_helper'

describe NewsFolder do
  before(:each) do
    @news = NewsFolder.new
  end
  it "should not be valid" do
    @news.should_not be_valid
  end

  it "should respond to #items" do
    @news.should respond_to(:items)
  end
end

describe "Cheezeburga News" do
  fixtures :all
  before(:each) do
    @news = contents(:cheezeburgaz)
  end
  it "should not be nil" do
    @news.should_not be_nil
  end
  it "should be valid" do
    @news.should be_valid
  end
  it do
    @news.should have_at_least(1).item
  end

  describe "last 5 items" do
    before(:each) do
      @items = @news.items.last(5)
    end
    it do
      @items.should_not be_empty
    end
    it "should contain the cookie (fails mysteriously)" do
      @cookie = contents(:ate_cookie)
      @items.collect(&:title).should include( @cookie.title )
    end
  end
end
