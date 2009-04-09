require File.dirname(__FILE__) + '/../../spec_helper'

describe Pages::LayoutHelper do
  fixtures :pages, :grids, :renderings, :parts

  describe 'render_tree from Grid' do
    before(:each) do
      @html = nil
    end
    def html
      @html ||= helper.render_tree grids(:main_vs_sidebar), 
        :include => [:children], 
        :partial => 'list_item'
    end

    it "should succeed" do
      lambda { html }.should_not raise_error
      html.should_not be_blank
    end

    it "should render a (js-collapsable tree)" do
      html.should have_tag 'li.grid_1' do
        with_tag 'a', /Main vs Sidebar/ 
        with_tag 'ul' do
          with_tag 'li.grid_2' do
            with_tag 'a', /Main \(Menu vs Content\)/ 
            with_tag 'ul' do
              with_tag 'li.grid_4' do
                with_tag 'a', /Menu/ 
              end
              with_tag 'li.grid_5' do
                with_tag 'a', /Content/ 
              end
            end
          end
          with_tag 'li.grid_3' do
            with_tag 'a', /Sidebar/ 
          end
        end
      end
    end
  end

  describe 'render_tree from Page' do
    before(:each) do
      @html = nil
    end
    def html
      pending("implement YAML Grids first")
      @html ||= helper.render_tree pages(:ddm), 
        :include => [:layout, :children, :renderings], 
        :partial => 'list_item'
    end

    it "should succeed" do
      pending("implement YAML Grids first")
      lambda { html }.should_not raise_error
      html.should_not be_blank
    end

  end
  
end
