require File.dirname(__FILE__) + '/../spec_helper'

describe Grid do
  before(:each) do
    @grid = Grid.new
  end

  it "should not be valid" do
    @grid.should_not be_valid
  end

  it "should be valid if we set a yui" do
    @grid.yui = 'yui-u'
    @grid.should be_valid
  end

  describe 'after save' do
    before(:each) do
      @grid.yui = Grid::Types.keys.first
      @grid.save!
    end
    it "should have lft and rgt attributes" do
      @grid.lft.should_not be_nil
      @grid.rgt.should_not be_nil
    end

    describe ', setting the grid_to "50-50"' do
      before(:each) do
        @grid.update_attribute :yui, 'yui-g'
      end
      it "should change its gridclass to '50-50'" do
        @grid.yui.should == 'yui-g'
      end

      it "should change its ideal number of children to 2" do
        @grid.ideal_children_count.should == 2
      end

      it "should add two children automatically" do
        @grid.children.length.should == 2
      end

      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :yui, 'yui-gd'
        end
        it "should change its gridclass to 33-66" do
          @grid.yui.should == 'yui-gd'
        end
        it "should not change its ideal number of children" do
          @grid.ideal_children_count.should == 2
        end
        it "should not add more children" do
          @grid.ideal_children_count.should == 2
        end
      end
      describe ', setting the grid_to "33-33-33"' do
        before(:each) do
          @grid.update_attribute :yui, 'yui-gb'
        end
        it "should change its gridclass to '33-33-33'" do
          @grid.yui.should == 'yui-gb'
        end

        it "should change its ideal number of children to 3" do
          @grid.ideal_children_count.should == 3
        end

        it "should add three children automatically" do
          @grid.children.length.should == 3
        end
        describe ', switching that to "33-66"' do
          before(:each) do
            @grid.update_attribute :yui, 'yui-gd'
          end
          it "should change its gridclass to 33-66" do
            @grid.yui.should == 'yui-gd'
          end
          it "should change its ideal number of children to 2" do
            @grid.ideal_children_count.should == 2
          end
          it "should not delete the additional child" do
            @grid.children.length.should == 3
          end
        end
      end
    end

    describe ', setting the grid_to "33-33-33"' do
      before(:each) do
        @grid.update_attribute :yui, 'yui-gb'
      end
      it "should change its gridclass to '33-33-33'" do
        @grid.yui.should == 'yui-gb'
      end

      it "should change its ideal number of children to 3" do
        @grid.ideal_children_count.should == 3
      end

      it "should add three children automatically" do
        @grid.children.length.should == 3
      end
      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :yui, 'yui-gd'
        end
        it "should change its gridclass to 33-66" do
          @grid.yui.should == 'yui-gd'
        end
        it "should change its ideal number of children to 2" do
          @grid.ideal_children_count.should == 2
        end
        it "should not delete the additional child" do
          @grid.children.length.should == 3
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
  end
end

describe "Creating a 3/4 - 1/4 grid" do
  before(:each) do
    @grid = Grid.new_by_yui('yui-ge')
    @grid.save!
  end
  it "should still be 3/4 - 1/4" do
    @grid.yui.should == 'yui-ge'
  end
  it "should have ideally two children" do
    @grid.ideal_children_count.should == 2
  end
  it "should have exactly two children" do
    @grid.children.length.should == 2
  end
end
