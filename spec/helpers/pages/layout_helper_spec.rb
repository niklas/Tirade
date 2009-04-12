require File.dirname(__FILE__) + '/../../spec_helper'

describe Pages::LayoutHelper do
  fixtures :pages, :grids, :renderings, :parts

  describe 'render_tree from Page' do
    before(:each) do
      helper.stub!(:render).with(:partial => 'grids/list_item').and_return('Data')
      helper.stub!(:single_item).and_return('SINGLE')
      @html = nil
    end
    def html
      @html ||= helper.render_tree pages(:ddm)
    end

    it "should succeed" do
      lambda { html }.should_not raise_error
      html.should_not be_blank
    end

    it "should render a tree with all grids" do
      html.should have_tag 'ul.tree.tree_root' do
        with_tag 'li.page_1337' do
          #with_tag 'a', /DDM/
          with_tag 'ul.tree' do
            with_tag 'li.grid_1' do
              #with_tag 'a', /Main vs Sidebar/ 
              with_tag 'ul.tree' do
                with_tag 'li.grid_2' do
                  #with_tag 'a', /Main \(Menu vs Content\)/ 
                  with_tag 'ul.tree' do
                    with_tag 'li.grid_4' do
                      #with_tag 'a', /Menu/ 
                    end
                    with_tag 'li.grid_5' do
                      #with_tag 'a', /Content/ 
                    end
                  end
                end
                with_tag 'li.grid_3' do
                  #with_tag 'a', /Sidebar/ 
                end
              end
            end
          end
        end
      end
    end
  end
  
end
