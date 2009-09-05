require File.dirname(__FILE__) + '/../spec_helper'

describe Document do
  it "should act as content" do
    Document.should be_acts_as(:content)
  end

  it "should act as slugged" do
    Document.should be_acts_as(:slugged)
  end

  describe "scopes_grouped_by_column" do
    subject { Document.scopes_grouped_by_column }
    it { should be_a Hash }
    it { should have_key('id') }
    it { should have_key('title') }
    it { should have_key('slug') }
    it { should have_key('description') }
    it { should have_key('body') }
    it { should have_key('created_at') }
    it { should have_key('updated_at') }
  end

  describe "scopes for title" do
    subject { Document.scopes_for_column(:title) }
    it { should be_an Array }
    it { should include 'like'}
    it { should include 'equals'}
    it { should include 'does_not_equal'}
    it { should include 'begins_with'}
    it { should include 'ends_with'}
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

    it "should use the 'de' title as title from default locale, because latter does not exist" do
      @document.title_from_default_locale.should_not be_blank
    end

    it "should create default translation when saving" do
      lambda { @document.save }.should change(DocumentTranslation, :count).by(1)
    end

    describe "saved" do
      before( :each ) do
        @document.save
      end

      it "should have a 'en' translation (default)" do
        en = @document.globalize_translations.locale_equals('en')
        en.should_not be_empty
      end
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
          @document.globalize_translations.locale_equals('de').should_not be_empty
        end

        it "should keep the 'en' locale" do
          @updating.call
          @document.globalize_translations.locale_equals('en').should_not be_empty
        end

        it "should keep the 'de' locale" do
          @updating.call
          @document.reload
          @document.title.should == 'Deutscher Titel'
          @document.title.locale.should == :de
        end

        it "should keep the title from default locale" do
          @updating.call
          @document.reload
          @document.title_from_default_locale.should_not == @document.title
        end

      end

      context "updating attributes with specified locale (not neccessary in the moment)" do
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
