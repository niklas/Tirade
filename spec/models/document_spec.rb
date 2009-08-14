require File.dirname(__FILE__) + '/../spec_helper'

describe Document do
  it "should act as content" do
    Document.should be_acts_as(:content)
  end

  it "should act as slugged" do
    Document.should be_acts_as(:slugged)
  end

  describe "from Factory" do
    before( :each ) do
      @document = Factory(:document)
    end

    it "should be a Document" do
      @document.should be_a(Document)
    end

    it "should be valid" do
      @document.should be_valid
    end

    it "should have a title" do
      @document.title.should_not be_blank
    end


    describe "in locale 'de'" do
      before( :each ) do
        @old_locale = I18n.locale
        I18n.locale = :de
      end

      after( :each ) do
        I18n.locale = @old_locale
      end

      it "should fall back on en locale" do
        @document.title.should be_fallback
        @document.title.locale.should == :en
        @document.title.requested_locale.should == :de
      end

      it "should still have a title by falling back" do
        @document.title.should_not be_blank
      end
    end

  end
end
