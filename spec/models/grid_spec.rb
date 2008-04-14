require File.dirname(__FILE__) + '/../spec_helper'

describe Grid do
  before(:each) do
    @grid = Grid.new
  end

  it "should not be valid" do
    @grid.should_not be_valid
  end

  it "should be valid if we set a grid_class" do
    @grid.grid_class = Grid::Types.keys.first
    @grid.should be_valid
  end

  describe 'after save' do
    before(:each) do
      @grid.grid_class = Grid::Types.keys.first
      @grid.save!
    end
    it "should have lft and rgt attributes" do
      @grid.lft.should_not be_nil
      @grid.rgt.should_not be_nil
    end

    describe ', adding a child' do
      before(:each) do
        @grid.add_child
      end
      it "should change its gridclass to 'single'" do
        @grid.grid_class.should == 'single'
      end

      it "should change its ideal number of children to 1" do
        @grid.ideal_children_count.should == 1
      end

      describe ', adding a second child' do
        before(:each) do
          @grid.add_child
        end
        it "should change its gridclass to 50-50" do
          @grid.grid_class.should == 'yui-g'
        end
        it "should change its ideal number of children to 2" do
          @grid.ideal_children_count.should == 2
        end

        describe ', adding a third child' do
          before(:each) do
            @grid.add_child
          end
          it "should change its gridclass to 33-33-33" do
            @grid.grid_class.should == 'yui-gb'
          end
          it "should change its ideal number of children to 3" do
            @grid.ideal_children_count.should == 3
          end
        end
      end
    end
  end


end

