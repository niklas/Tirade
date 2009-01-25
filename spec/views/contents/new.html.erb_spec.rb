require File.dirname(__FILE__) + '/../../spec_helper'

describe "/contents/new.html.erb" do
  include ContentsHelper
  
  describe "for a NewsItem" do
    before(:each) do
      @content = mock_model(NewsItem)
      @content.stub!(:new_record?).and_return(true)
      @content.stub!(:markup?).with(:description).and_return(true)
      @content.stub!(:markup?).with(:any).and_return(true)
      @content.stub!(:title).and_return("New News")
      @content.stub!(:description).and_return("nothing")
      @content.stub!(:body).and_return("great news everyone!")
      @content.stub!(:type).and_return("NewsItem")
      @content.stub!(:wanted_parent_id).and_return(3)
      assigns[:content] = @content
    end

    it "should render new form" do
      render "/contents/new.html.erb"

      response.should have_tag("form[action=?][method=post]", contents_path) do
        without_tag('p.default.warning')
        without_tag("input#content_state[name=?]", "content[state]")
        without_tag("input#content_position[name=?]", "content[position]")
        without_tag("input#content_lft[name=?]", "content[lft]")
        without_tag("input#content_rgt[name=?]", "content[rgt]")
        without_tag("textarea#content_body", "content[body]")
        with_tag("input#content_title[name=?]", "content[title]")
        #with_tag('p') do
        #  with_tag('label', 'Description')
        #  with_tag("textarea#content_description[name=?]", "content[description]")
        #end
        with_tag("textarea#content_body[name=?]", "content[body]")
        #with_tag('p.type') do
        #  with_tag('label', 'Type')
        #  with_tag("select#content_type[name=?]", "content[type]")
        #end
        with_tag("select#content_wanted_parent_id[name=?]", "content[wanted_parent_id]")
      end
    end
  end

  describe "for a Document" do
    before(:each) do
      @content = mock_model(Document)
      @content.stub!(:new_record?).and_return(true)
      @content.stub!(:title).and_return("New Document")
      @content.stub!(:description).and_return("Document Description")
      @content.stub!(:body).and_return("Document Body")
      @content.stub!(:type).and_return("Document")
      @content.stub!(:wanted_parent_id).and_return(3)
      assigns[:content] = @content
    end

    it "should render new form" do
      render "/contents/new.html.erb"
      
      response.should have_tag("form[action=?][method=post]", contents_path) do
        without_tag('p.default.warning')
        without_tag("input#content_state[name=?]", "content[state]")
        without_tag("input#content_position[name=?]", "content[position]")
        without_tag("input#content_lft[name=?]", "content[lft]")
        without_tag("input#content_rgt[name=?]", "content[rgt]")
        with_tag("input#content_title[name=?]", "content[title]")
        with_tag("textarea#content_description[name=?]", "content[description]")
        with_tag("textarea#content_body[name=?]", "content[body]")
        #with_tag('div.type') do
        #  with_tag('label', 'Type')
        #  with_tag("select#content_type[name=?]", "content[type]")
        #end
        with_tag("select#content_wanted_parent_id[name=?]", "content[wanted_parent_id]")
      end
    end
  end

  describe "for a completly unknown content type that inherits directly from Content" do
    before(:each) do
      class ZweiHimmelHundeAufDemWegZurHoelle < Content; end
      @content = mock_model(ZweiHimmelHundeAufDemWegZurHoelle)
      @content.stub!(:new_record?).and_return(true)
      @content.stub!(:title).and_return("Hölle hölle hölle")
      @content.stub!(:type).and_return("ZweiHimmelHundeAufDemWegZurHoelle")
      @content.stub!(:wanted_parent_id).and_return(88-66+23)
      assigns[:content] = @content
    end

    it "should render new form with default fields and warning" do
      render "/contents/new.html.erb"
      
      response.should have_tag("form[action=?][method=post]", contents_path) do
        with_tag('p.default.warning') do
          with_tag('pre', %r~Missing template contents/_zwei_himmel_hunde_auf_dem_weg_zur_hoelle_fields~)
        end
        without_tag("input#content_state[name=?]", "content[state]")
        without_tag("input#content_position[name=?]", "content[position]")
        without_tag("input#content_lft[name=?]", "content[lft]")
        without_tag("input#content_rgt[name=?]", "content[rgt]")
        with_tag("input#content_title[name=?]", "content[title]")
      end
    end
  end

  describe "for a completly unknown content type that inherits from Document" do
    before(:each) do
      class ZweiEinhalbHimmelHundeAufDemWegZurHoelle < Document; end
      @content = mock_model(ZweiEinhalbHimmelHundeAufDemWegZurHoelle)
      @content.stub!(:new_record?).and_return(true)
      @content.stub!(:title).and_return("Hölle hölle hölle")
      @content.stub!(:type).and_return("ZweiEinhalbHimmelHundeAufDemWegZurHoelle")
      @content.stub!(:description).and_return("Bud Spencer")
      @content.stub!(:body).and_return("Italo Zingarelli")
      @content.stub!(:wanted_parent_id).and_return(88-66+42)
      assigns[:content] = @content
    end

    it "should render new form for Document (its superclass)" do
      render "/contents/new.html.erb"
      
      response.should have_tag("form[action=?][method=post]", contents_path) do
        without_tag('p.default.warning')
        without_tag("input#content_state[name=?]", "content[state]")
        without_tag("input#content_position[name=?]", "content[position]")
        without_tag("input#content_lft[name=?]", "content[lft]")
        without_tag("input#content_rgt[name=?]", "content[rgt]")
        with_tag("input#content_title[name=?]", "content[title]")
        with_tag("textarea#content_description[name=?]", "content[description]")
        with_tag("textarea#content_body[name=?]", "content[body]")
        #with_tag('p.type') do
        #  with_tag('label', 'Type')
        #  with_tag("select#content_type[name=?]", "content[type]")
        #end
        with_tag("select#content_wanted_parent_id[name=?]", "content[wanted_parent_id]")
      end
    end
  end
end


