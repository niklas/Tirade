require File.dirname(__FILE__) + '/../spec_helper'

describe Grid do
  before(:each) do
    @grid = Grid.new
  end

  it "should not be valid" do
    @grid.should_not be_valid
  end

  it "should be valid if we set a grid_class" do
    @grid.grid_class = 'yui-u'
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

    describe ', setting the grid_to "50-50"' do
      before(:each) do
        @grid.update_attribute :grid_class, 'yui-g'
      end
      it "should change its gridclass to '50-50'" do
        @grid.grid_class.should == 'yui-g'
      end

      it "should change its ideal number of children to 2" do
        @grid.ideal_children_count.should == 2
      end

      it "should add two children automatically" do
        @grid.children.length.should == 2
      end

      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :grid_class, 'yui-gd'
        end
        it "should change its gridclass to 33-66" do
          @grid.grid_class.should == 'yui-gd'
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
          @grid.update_attribute :grid_class, 'yui-gb'
        end
        it "should change its gridclass to '33-33-33'" do
          @grid.grid_class.should == 'yui-gb'
        end

        it "should change its ideal number of children to 3" do
          @grid.ideal_children_count.should == 3
        end

        it "should add three children automatically" do
          @grid.children.length.should == 3
        end
        describe ', switching that to "33-66"' do
          before(:each) do
            @grid.update_attribute :grid_class, 'yui-gd'
          end
          it "should change its gridclass to 33-66" do
            @grid.grid_class.should == 'yui-gd'
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
        @grid.update_attribute :grid_class, 'yui-gb'
      end
      it "should change its gridclass to '33-33-33'" do
        @grid.grid_class.should == 'yui-gb'
      end

      it "should change its ideal number of children to 3" do
        @grid.ideal_children_count.should == 3
      end

      it "should add three children automatically" do
        @grid.children.length.should == 3
      end
      describe ', switching that to "33-66"' do
        before(:each) do
          @grid.update_attribute :grid_class, 'yui-gd'
        end
        it "should change its gridclass to 33-66" do
          @grid.grid_class.should == 'yui-gd'
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


end

