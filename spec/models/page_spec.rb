require File.dirname(__FILE__) + '/../spec_helper'

describe "A Page with a title" do
  before(:each) do
    @page = Page.new(
      :title => "A Simple Page"
    )
  end

  it "should be able to call its parent" do
    @page.should respond_to(:parent)
  end
end



describe "The Pages in the fixtures" do
  fixtures :pages, :grids

  before(:each) do
    Page.rebuild!
    @pages = Page.find(:all)
  end

  it "should be there" do
    @pages.should_not be_empty
  end

  it "should be valid" do
    @pages.each do |page|
      page.should be_valid
    end
  end

  it "should have an url" do
    @pages.each do |page|
      page.url.should_not be_nil
    end
  end

  it "should be findable by its url" do
    @pages.each do |page|
      Page.find_by_url(page.url).id.should == page.id
    end
  end

  it "should generate the correct url" do
    @pages.each do |page|
      page.generated_url.should == page.url
    end
  end

  it "should have a final_layout" do
    @pages.each do |page|
      page.final_layout.should_not be_nil
    end
  end

  describe ", the page about Huge Brutal Hammers" do
    before(:each) do
      @page = pages(:hammers)
    end
    it "should have a special layout" do
      @page.layout.id.should == grids(:layout33_33_33).id
    end
    it "should have its own final layout" do
      @page.final_layout.id.should == @page.layout.id
    end
    it "should know all its ancestors" do
      ancestors = @page.ancestors
      ancestors.should include( pages(:main) )
      ancestors.should include( pages(:portal) )
      ancestors.should include( pages(:children_section) )
    end
  end

  describe ', creating a new page under meta/about' do
    before(:each) do
      @page = Page.new(
        :title => 'yourself',
        :wanted_parent_id => pages(:about).id
      )
    end
    it "should be valid" do
      @page.should be_valid
    end
    it "should still be a new record" do
      @page.should be_new_record
    end
    describe "Saving and reloading it" do
      before(:each) do
        lambda do
          @page.save!
          @page = Page.find(@page.id)
        end.should_not raise_error
      end
      it "should still be valid" do
        @page.should be_valid
      end
      it "should not be a new record anymore" do
        @page.should_not be_new_record
      end
      it "should have a correct parent_id" do
        @page.parent_id.should == pages(:about).id
      end
      it "should have the about page as parent" do
        @page.parent.should == pages(:about)
      end
      it "should generate the proper url" do
        @page.generated_url.should == 'meta/about/yourself'
      end
      it "should have the proper url" do
        @page.url.should == 'meta/about/yourself'
      end

      describe "Setting a new title, reloading" do
        before(:each) do
          lambda do
            @page.title = 'your neighbor'
            @page.save!
            @page = Page.find(@page.id)
          end.should_not raise_error
        end
        it "should still be valid" do
          @page.should be_valid
        end
        it "should not be a new record anymore" do
          @page.should_not be_new_record
        end
        it "should have a correct parent_id" do
          @page.parent_id.should == pages(:about).id
        end
        it "should have the about page as parent" do
          @page.parent.should == pages(:about)
        end
        it "should have the proper url" do
          @page.url.should == 'meta/about/your-neighbor'
        end
      end
    end
  end
end


describe "The main Page with all fixtures" do
  fixtures :all
  before(:each) do
    Page.rebuild!
    Grid.rebuild!
    Content.rebuild!
    @page = pages(:main)
  end
  it "should have the right final_layout" do
    @page.final_layout.id.should == grids(:layout50_50).id
  end
  it "should have some renderings" do
    @page.should have_at_least(3).renderings
  end
  # FIXME does not work wiht polymorphic (see page.rb)
  #it "should have some contents" do
  #  @page.should have_at_least(2).contents
  #end
  it "should have some contents"
  it "should have some parts" do
    @page.should have_at_least(2).parts
  end
  it "should have some grids" do
    @page.should have_at_least(3).grids
  end
  it "should have some renderings" do
    @page.should have_at_least(3).renderings
  end

  describe ", rendering it" do
    before(:each) do
      @html = @page.render
    end
    it "should not be empty" do
      @html.should_not be_empty
    end
    it "should have the complete page structure" do
      @html.should have_tag('div#doc') do
        with_tag('div.grid.yui-g') do
          with_tag('div.first.grid.yui-u') do
            with_tag('div.rendering.simple_preview.document') do
              with_tag('h2', 'Welcome')
              with_tag('p', /big hug/)
            end
          end
          with_tag('div.first.grid + div.grid.yui-u') do
            with_tag('div.rendering.simple_preview.document') do
              with_tag('h2','Introduction')
              with_tag('p',/Tirade is a CMS/)
            end
          end
        end
      end
    end
  end

  describe "switching the layout to a new one" do
    before(:each) do
      @layout = Grid.create!( :yui => 'yui-ge' )
      @page.update_attribute(:layout, @layout )
      @page = Page.find(@page.id)
    end
    it "should have the new layout set" do
      @page.layout.should == @layout
    end
    it "should have the standard grids" do
      @page.should have(3).grids
    end
    it "should not have any renderings anymore" do
      pending("all renderings are found, not just the visible")
      @page.should have(:no).visible_renderings
    end
    it "should not have any parts anymore" do
      pending("all parts are found, not just the visible")
      @page.should have(:no).parts
    end
  end
end

describe "Having all fixtures loaded" do
  fixtures :all
  it "destroying the about page should succeed" do
    # this checks for the AR#update_all monkepatch
    lambda do
      pages(:about).destroy
    end.should_not raise_error
  end
end
