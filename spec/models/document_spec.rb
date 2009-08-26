require File.dirname(__FILE__) + '/../spec_helper'

describe Document do
  it "should act as content" do
    Document.should be_acts_as(:content)
  end

  it "should act as slugged" do
    Document.should be_acts_as(:slugged)
  end

  describe "build from Factory" do
    before( :each ) do
      @document = Factory.build(:document)
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

    it "should create default translation when saving" do
      lambda { @document.save }.should change(DocumentTranslation, :count).by(1)
    end


    describe "saved, switching to locale 'de'" do
      before( :each ) do
        @document.save
        @old_locale = I18n.locale
        I18n.locale = :de
      end

      after( :each ) do
        I18n.locale = @old_locale
      end

      it "should fall back on 'en' locale" do
        @document.title.should be_fallback
        @document.title.locale.should == :en
        @document.title.requested_locale.should == :de
      end

      it "should still have a title by falling back" do
        @document.title.should_not be_blank
      end

      context "updating attributes" do
        before( :each ) do
          @updating = lambda {
            @document.update_attributes(:title => 'Deutscher Titel')
          }
        end
        it "should create 'de' locale" do
          @updating.should change(@document.globalize_translations, :count).by(1)
        end

        it "should keep the 'de' locale" do
          @updating.call
          @document.reload
          @document.title.should == 'Deutscher Titel'
          @document.title.locale.should == :de
        end
      end

      context "updating attributes with specified locale" do
        before( :each ) do
          @attributes = {
            :translations => {
              :de => {:title => 'Deutscher Titel'}
            }
          }
          @updating = lambda {
            @document.update_attributes(@attributes)
          }
        end
        it "should create 'de' locale" do
          @updating.should change(@document.globalize_translations, :count).by(1)
        end

        it "should keep the 'de' locale" do
          @updating.call
          @document.reload
          @document.title.should be_a(Globalize::Translation)
          @document.title.should == 'Deutscher Titel'
          @document.title.locale.should == :de
        end
      end
    end

  end

end
