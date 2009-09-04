require File.dirname(__FILE__) + '/../../spec_helper'

describe "/grids/_grid.html.haml" do
  fixtures :pages, :grids, :renderings, :contents
  include RenderHelper
  before( :each ) do
    template.view_paths.unshift 'app/views'
  end

  it "should succeed" do
    lambda { template.render_grid Factory(:grid) }.should_not raise_error
  end

  it "should render the right column" do
    @html = template.render_grid grids(:layout_50_50_2)
    @html.should have_tag('div.grid.subcr.50_50_right')
  end

  it "should render the right column in main page" do
    @html = template.render_grid_in_page grids(:layout_50_50_2), pages(:main)
    @html.should have_tag('div.grid.subcr.50_50_right') do
      with_tag('div.rendering.simple_preview.document') do
        with_tag('h2')
        with_tag('p')
      end
    end
  end

  it "should render the left column" do
    @html = template.render_grid grids(:layout_50_50_1)
    @html.should have_tag('div.grid.50_50_left.subcl')
  end

  it "should render the left column in main page" do
    @html = template.render_grid_in_page grids(:layout_50_50_1), pages(:main)
    @html.should have_tag('div.grid.subcl.50_50_left') do
      with_tag('div.rendering.simple_preview.document') do
        without_tag('h2')
        with_tag('p')
      end
    end
  end


  it "should render both columns in the 50/50 layout" do
    @html = template.render_grid grids(:layout50_50)
    @html.should have_tag('div.grid.50_50.grid_5050.subcolumns') do
      with_tag('div.col.c50l div.grid.50_50_left.subcl')
      with_tag('div.col.c50l + div.col.c50r div.grid.50_50_right.subcr')
    end
  end

  it "should render both columns in the 50/50 layout for the main page" do
    @html = template.render_grid_in_page grids(:layout50_50), pages(:main)
    @html.should have_tag('div.grid.subcolumns') do
      with_tag('div.col.c50l div.grid.subcl.50_50_left') do
        with_tag('div.rendering.simple_preview.document') do
          with_tag('p')
        end
      end
      with_tag('div.col.c50l + div.col.c50r div.grid.subcr.50_50_right') do
        with_tag('div.rendering.simple_preview.document') do
          with_tag('h2')
          with_tag('p')
        end
      end
    end
  end


  describe "replacing the left side with a new Grid" do
    before( :each ) do
      @replacement = Factory :grid, :title => 'Replacement', :float => 'l', :width => 50
      @grid = grids(:layout_50_50_1)
      @grid.update_attributes!(:replacement => @replacement)
      @rendering = Factory :rendering, :grid => @replacement, :css_classes_list => 'somewhere_else'
    end
    it "should keep the replacement" do
      @grid.replacement.should == @replacement
      grids(:layout_50_50_1).replacement.should == @replacement
      @replacement.should have(1).rendering
    end
    it "should render both columns in the 50/50 layout for the main page, replacing the left column" do
      @html = template.render_grid_in_page grids(:layout50_50), pages(:main)
      @html.should have_tag('div.grid.subcolumns') do
        with_tag('div.col.c50l div.grid.subcl.replacement') do
          with_tag('div.rendering.somewhere_else')
        end
        with_tag('div.col.c50l + div.col.c50r div.grid.subcr.50_50_right') do
          with_tag('div.rendering.simple_preview.document') do
            with_tag('h2')
            with_tag('p')
          end
        end
      end
    end
  end

end
