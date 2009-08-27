require File.dirname(__FILE__) + '/../../spec_helper'

describe "/grids/_grid.html.haml" do
  fixtures :pages, :grids, :renderings, :parts, :contents
  include RenderHelper
  before( :each ) do
    template.view_paths.unshift 'app/views'
    @page = pages(:ddm)
  end

  def html
    @html ||= template.render_page @page
  end


  it "should succeed" do
    lambda { template.render_page Factory(:page) }.should_not raise_error
  end

  it "should not wrap layout into a .col" do
    html.should_not have_tag('div.page > div.col')
  end

  it "should render the proper YAML tags"do 
    html.should have_tag 'div.page.page_1337'do 
      with_tag 'div#grid_1.subcolumns.grid.grid_1.main_vs_sidebar'do 
        with_tag 'div.col.c75l'do 
          with_tag 'div#grid_2.subcolumns.grid.grid_2.main_menu_vs_content'do 
            with_tag 'div.col.c38l'do 
              with_tag 'div#grid_4.subcl.leaf.grid.grid_4.menu'do 
                #with_tag 'div.rendering.menu'do 
                #  with_tag 'ul'            #      | | |   |  
                #end                        #     /  | |   |                       
                #with_tag 'div.rendering.logo'do 
                #  with_tag 'img'           #      | | |   |  
                #end                        #     /  / |   |                       
              end                          #          |   |                   
            end                            #          |   |                   
          end                              #          /   |                   
          with_tag 'div.col.c62r'do 
            with_tag 'div#grid_5.subcr.grid.grid_5.content'do 
              with_tag 'div.rendering.rendering_13371.document'
            end                            #              |  /              
          end                              #              |                 
        end                                #              |
        with_tag 'div.col.c25r'do 
          with_tag 'div#grid_3.subcr.grid.grid_3.sidebar'
        end                                #              |
      end                                  #              /
    end                                
  end

end
