require File.dirname(__FILE__) + '/../spec_helper'

describe Grid, :type => :helper do
  before(:each) do
    @grid = Grid.new
  end

  it "should not be valid" do
    @grid.should_not be_valid
  end

  it "should be valid if we set a division" do
    @grid.division = 'leaf'
    @grid.should be_valid
  end

  it "should notice the change on #division" do
    @grid.division = 'leaf'
    @grid.should be_division_changed
  end

  describe 'after save' do
    before(:each) do
      @grid.division = Grid::Divisions.keys.first
      @grid.save!
    end
    it "should have lft and rgt attributes" do
      @grid.lft.should_not be_nil
      @grid.rgt.should_not be_nil
    end

    it "should be root" do
      @grid.should be_root
    end

    describe ', setting the grid_to "50-50"' do
      before(:each) do
        @grid.division = '50-50'
        @grid.save!
      end
      it "should change its gridclass to 'subcolumns'" do
        @grid.own_css.should include('subcolumns')
      end

      it "should change its ideal number of children to 2" do
        @grid.ideal_children_count.should == 2
      end

      it "should add two children automatically" do
        @grid.children.length.should == 2
      end
      it "should have a proper name (for da humanz)" do
        @grid.name.should == '50% - 50%'
      end

      it "should still be known to its children" do
        @grid.children.each do |child|
          child.parent.should == @grid
          child.parent.division.should == @grid.division
          child.parent.name.should == @grid.name
        end
      end

      it "should give its children proper names" do
        @grid.children[0].name.should == '50%'
        @grid.children[1].name.should == '50%'
      end


      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :division, '33-66'
        end
        it "should change its gridclass to 'subcolumns'" do
          @grid.own_css.should include('subcolumns')
        end
        it "should not change its ideal number of children" do
          @grid.ideal_children_count.should == 2
        end
        it "should not add more children" do
          @grid.ideal_children_count.should == 2
        end
        it "should have a proper name (for da humanz)" do
          @grid.name.should == '33% - 66%'
        end
        it "should give its children proper names" do
          @grid.children[0].name.should == '33%'
          @grid.children[1].name.should == '66%'
        end
      end
      describe ', setting the grid_to "33-33-33"' do
        before(:each) do
          @grid.update_attribute :division, '33-33-33'
        end
        it "should change its gridclass to 'subcolumns'" do
          @grid.own_css.should include('subcolumns')
        end

        it "should change its ideal number of children to 3" do
          @grid.ideal_children_count.should == 3
        end

        it "should add three children automatically" do
          @grid.children.length.should == 3
        end
        it "should have a proper name (for da humanz)" do
          @grid.name.should == '33% - 33% - 33%'
        end
        it "should give its children proper names" do
          @grid.children[0].name.should == '33%'
          @grid.children[1].name.should == '33%'
          @grid.children[2].name.should == '33%'
        end
        describe ', switching that to "33-66"' do
          before(:each) do
            @grid.update_attribute :division, '33-66'
          end
          it "should change its gridclass to 'subcolumns'" do
            @grid.own_css.should include('subcolumns')
          end
          it "should change its ideal number of children to 2" do
            @grid.ideal_children_count.should == 2
          end
          it "should not delete the additional child" do
            @grid.children.length.should == 3
          end
          it "should have a proper name (for da humanz)" do
            @grid.name.should == '33% - 66%'
          end
          it "should give its children proper names" do
            @grid.children[0].name.should == '33%'
            @grid.children[1].name.should == '66%'
          end
        end
      end
    end

    describe ', setting the grid_to "33-33-33"' do
      before(:each) do
        @grid.update_attribute :division, '33-33-33'
      end
      it "should change its gridclass to 'subcolumns'" do
        @grid.own_css.should include('subcolumns')
      end

      it "should change its ideal number of children to 3" do
        @grid.ideal_children_count.should == 3
      end

      it "should add three children automatically" do
        @grid.children.length.should == 3
      end
      it "should have a proper name (for da humanz)" do
        @grid.name.should == '33% - 33% - 33%'
      end
      it "should give its children proper names" do
        @grid.children[0].name.should == '33%'
        @grid.children[1].name.should == '33%'
        @grid.children[2].name.should == '33%'
      end
      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :division, '33-66'
        end
        it "should change its ideal number of children to 2" do
          @grid.ideal_children_count.should == 2
        end
        it "should not delete the additional child" do
          @grid.children.length.should == 3
        end
        it "should have a proper name (for da humanz)" do
          @grid.name.should == '33% - 66%'
        end
        it "should give its children proper names" do
          @grid.children[0].name.should == '33%'
          @grid.children[1].name.should == '66%'
        end
      end
    end

  end

  describe "The Grids in the fixtures" do
    fixtures :all
    it "should know its parent" do
      grids(:layout50_50).parent.should be_nil
      grids(:layout_50_50_1).parent.id.should == grids(:layout50_50).id
      grids(:layout_50_50_2).parent.id.should == grids(:layout50_50).id
    end
    it "should know that it is the first child" do
      grids(:layout_50_50_1).should be_is_first_child
      grids(:layout_50_50_2).should_not be_is_first_child
    end
    it "should have a proper name (for da humanz)" do
      grids(:layout50_50).name.should == '50% - 50%'
    end
  end
end


describe "Creating a 3/4 - 1/4 grid" do
  before(:each) do
    @grid = Grid.new(:division => '75-25')
    @grid.save!
  end
  it "should still be 3/4 - 1/4" do
    @grid.division.should == '75-25'
  end
  it "should have ideally two children" do
    @grid.ideal_children_count.should == 2
  end
  it "should have exactly two children" do
    @grid.children.length.should == 2
  end
  it "should have a proper name (for da humanz)" do
    @grid.name.should == '75% - 25%'
  end
end


describe "The 50-50 Grid" do
  fixtures :all
  before(:each) do
    @grid = grids(:layout50_50)
    @old_pages = @grid.pages.to_a
  end
  it "should be valid" do
    @grid.should be_valid
  end

  it "should be root" do
    @grid.should be_root
  end

  it "should be used in a Page" do
    @grid.should have_at_least(1).page
    @old_pages.should_not be_empty
  end

  it "should be wrappable"
  it "should be explodable"

  #describe "wrapped into a simple yui-u.", "This Wrap" do
  #  before(:each) do
  #    @wrap = @grid.wrap!
  #    @wrap.reload
  #    @grid.reload
  #  end

  #  it "should be valid" do
  #    @wrap.should be_valid
  #  end

  #  it "should be a root node" do
  #    @wrap.should be_root
  #  end

  #  it "should be a yui-u" do
  #    @wrap.yui.should == 'yui-u'
  #  end

  #  it "should have the old grid as direct and only child" do
  #    @wrap.should have(1).child
  #    @grid.parent.should == @wrap
  #  end

  #  it "'s new child should not be a root node" do
  #    @grid.should_not be_root
  #  end

  #  it "should be used in a Page" do
  #    @wrap.should have_at_least(1).page
  #  end

  #  it "should be used in the same Pages as the former 50-50 Grid" do
  #    @old_pages.each do |page|
  #      page.reload.layout.should == @wrap
  #    end
  #    @old_pages.should_not be_empty
  #    @wrap.pages.should == @old_pages
  #  end

  #end

end

# describe "Exploding the left side of a 50-50 Grid" do
#   fixtures :all
#   before(:each) do
#     @grid = grids(:layout_50_50_2)
#     @exploding = lambda { @grid.explode! }
#   end
# 
#   it "should destroy itself and its siblings" do
#     sib_count = @grid.self_and_siblings.count
#     @exploding.should change(Grid, :count).by(-sib_count)
#   end
# 
#   it "should not destroy any Renderings" do
#     @exploding.should_not change(Rendering, :count)
#   end
# 
#   it "should change its parent to yui-u" do
#     @exploding.call
#     grids(:layout50_50).yui.should == 'yui-u'
#   end
# 
#   it "should move its renderings to its parent" do
#     @grid.renderings.should include(renderings(:main12))
#     @exploding.should change( grids(:layout50_50), :renderings_count).by_at_least(2)
#     pr = grids(:layout50_50).renderings
#     pr.should include(renderings(:main11))
#     pr.should include(renderings(:main12))
#   end
# end

describe 'A', Grid, 's Associations' do
  it 'should include Renderings' do
    Grid.reflections[:renderings].should_not be_nil
  end
end

describe Grid, "structure of DDM Page" do
  fixtures :pages, :grids, :renderings, :parts, :contents

  before(:each) do
    @page = pages(:ddm)
  end
  
  it "should have a rendering in content grid" do
    renderings(:ddm_welcome).should_not be_nil
    @page.should have_at_least(1).renderings_for_grid( grids(:content) )
  end

  it "should provide correct CSS classes" do
    grids(:main_vs_sidebar).own_css.should include('subcolumns')
    grids(:main_vs_sidebar).wrapper_css.should be_blank
    grids(:main_vs_sidebar).children_css.should include('c75l')
    grids(:main_vs_sidebar).children_css.should include('c25r')

    grids(:menu_vs_content).own_css.should include('subcolumns')
    grids(:menu_vs_content).wrapper_css.should == 'c75l'
    grids(:menu_vs_content).children_css.should include('c38l')
    grids(:menu_vs_content).children_css.should include('c62r')

    grids(:menu).own_css.should include('subcl')
    grids(:menu).wrapper_css.should == 'c38l'
    grids(:menu).children_css.should be_empty

    grids(:sidebar).own_css.should include('subcr')
    grids(:sidebar).wrapper_css.should == 'c25r'
    grids(:sidebar).children_css.should be_empty

    grids(:content).own_css.should include('subcr')
    grids(:content).wrapper_css.should == 'c62r'
    grids(:content).children_css.should be_empty
  end

end
