require File.dirname(__FILE__) + '/../spec_helper'


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
    grids(:main_vs_sidebar).yaml_sub_class.should include('subcolumns')
    grids(:main_vs_sidebar).yaml_column_class.should be_blank

    grids(:menu_vs_content).yaml_sub_class.should include('subcolumns')
    grids(:menu_vs_content).yaml_column_class.should == 'c75l'

    grids(:menu).yaml_sub_class.should include('subcl')
    grids(:menu).yaml_column_class.should == 'c38l'

    grids(:sidebar).yaml_sub_class.should include('subcr')
    grids(:sidebar).yaml_column_class.should == 'c25r'

    grids(:content).yaml_sub_class.should include('subcr')
    grids(:content).yaml_column_class.should == 'c62r'
  end

end

describe Grid, 'with' do
  def self.describe_valid_column(description, attributes={})
    describe description do
      before( :all ) do
        @sub    ||= attributes.delete(:sub)
        @column ||= attributes.delete(:column)
        @grid = Factory :grid, attributes
      end
      it "shoud be valid" do
        @grid.should be_valid
      end
      it "should provide proper YAML CSS classes" do
        @grid.yaml_sub_class.should == @sub
        @grid.yaml_column_class.should == @column
      end
    end
  end
  describe_valid_column '50% floating left' , :width => 50, :float => 'l', :column => 'c50l', :sub => 'subcl'
  describe_valid_column '50% floating right', :width => 50, :float => 'r', :column => 'c50r', :sub => 'subcr'
  describe_valid_column '25% floating left' , :width => 25, :float => 'l', :column => 'c25l', :sub => 'subcl'
  describe_valid_column '25% floating right', :width => 25, :float => 'r', :column => 'c25r', :sub => 'subcr'
  describe_valid_column '75% floating left' , :width => 75, :float => 'l', :column => 'c75l', :sub => 'subcl'
  describe_valid_column '75% floating left' , :width => 75, :float => 'l', :column => 'c75l', :sub => 'subcl'
  describe_valid_column '33% floating left' , :width => 33, :float => 'l', :column => 'c33l', :sub => 'subcl'
  describe_valid_column '33% not floating'  , :width => 33, :float => nil, :column => 'c33l', :sub => 'subc'
  describe_valid_column '33% floating right', :width => 33, :float => 'r', :column => 'c33r', :sub => 'subcr'
  describe_valid_column '66% floating left',  :width => 66, :float => 'l', :column => 'c66l', :sub => 'subcl'
  describe_valid_column '66% floating right', :width => 66, :float => 'r', :column => 'c66r', :sub => 'subcr'
  describe_valid_column '38% floating right', :width => 38, :float => 'r', :column => 'c38r', :sub => 'subcr'
  describe_valid_column '38% floating right', :width => 38, :float => 'r', :column => 'c38r', :sub => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :column => 'c62r', :sub => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :column => 'c62r', :sub => 'subcr'
  describe_valid_column '100% not floating' , :width =>100, :float => nil, :column => nil, :sub => 'subcolumns'

end


describe "empty", Grid do
  before( :each ) do
    @grid = Factory :grid, :width => 100, :float => nil
  end
  it "should be a wrapper" do
    @grid.should be_wrapper
  end
  it "should be empty" do
    @grid.should be_empty
  end

  def self.describe_children_creation_by_division(division, children_attributes)
    describe "updating division to #{division}" do
      before( :each ) do
        @updating = lambda { @grid.update_attributes!(:division =>division) }
      end
      it "should succeed" do
        @updating.should_not raise_error
      end
      it "should create children with proper floats and widths" do
        @updating.should change(@grid.children, :count).by(children_attributes.size)
        children_attributes.zip(@grid.children).each do |attrs,child|
          child.should_not be_nil
          attrs.each do |key, val|
            child.send(key).should == val
          end
        end
      end
    end
  end

  describe_children_creation_by_division '50-50', [
    {:width => 50, :float => 'l'},
    {:width => 50, :float => 'r'}
  ]
  describe_children_creation_by_division '33-33-33', [
    {:width => 33, :float => 'l'},
    {:width => 33, :float => 'l'},
    {:width => 33, :float => 'r'}
  ]
  describe_children_creation_by_division '25-75', [
    {:width => 25, :float => 'l'},
    {:width => 75, :float => 'r'}
  ]
  describe_children_creation_by_division '75-25', [
    {:width => 75, :float => 'l'},
    {:width => 25, :float => 'r'}
  ]
  describe_children_creation_by_division '33-66', [
    {:width => 33, :float => 'l'},
    {:width => 66, :float => 'r'}
  ]
  describe_children_creation_by_division '66-33', [
    {:width => 66, :float => 'l'},
    {:width => 33, :float => 'r'}
  ]
  describe_children_creation_by_division '38-62', [
    {:width => 38, :float => 'l'},
    {:width => 62, :float => 'r'}
  ]
  describe_children_creation_by_division '62-38', [
    {:width => 62, :float => 'l'},
    {:width => 38, :float => 'r'}
  ]
  describe_children_creation_by_division 'leaf', []
  describe_children_creation_by_division 'wrap', []

end
