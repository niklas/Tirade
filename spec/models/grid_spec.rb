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
    pending("fix later")
    renderings(:ddm_welcome).should_not be_nil
    @page.should have_at_least(1).renderings_for_grid( grids(:content) )
  end

  it "should provide correct CSS classes" do
    pending("fix later")
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

describe Grid, 'with' do
  def self.describe_valid_column(description, attributes={})
    describe description do
      before( :all ) do
        @yaml         ||= attributes.delete(:yaml)
        @yaml_content ||= attributes.delete(:yaml_content)
        @grid = Factory :grid, attributes
      end
      it "shoud be valid" do
        @grid.should be_valid
      end
      it "should provide proper YAML CSS classes" do
        @grid.yaml_class.should == @yaml
        @grid.yaml_content_class.should == @yaml_content
      end
    end
  end
  describe_valid_column '50% floating left' , :width => 50, :float => 'l', :yaml => 'c50l', :yaml_content => 'subcl'
  describe_valid_column '50% floating right', :width => 50, :float => 'r', :yaml => 'c50r', :yaml_content => 'subcr'
  describe_valid_column '25% floating left' , :width => 25, :float => 'l', :yaml => 'c25l', :yaml_content => 'subcl'
  describe_valid_column '25% floating right', :width => 25, :float => 'r', :yaml => 'c25r', :yaml_content => 'subcr'
  describe_valid_column '75% floating left' , :width => 75, :float => 'l', :yaml => 'c75l', :yaml_content => 'subcl'
  describe_valid_column '75% floating left' , :width => 75, :float => 'l', :yaml => 'c75l', :yaml_content => 'subcl'
  describe_valid_column '33% floating left' , :width => 33, :float => 'l', :yaml => 'c33l', :yaml_content => 'subcl'
  describe_valid_column '33% not floating'  , :width => 33, :float => nil, :yaml => 'c33l', :yaml_content => 'subc'
  describe_valid_column '33% floating right', :width => 33, :float => 'r', :yaml => 'c33r', :yaml_content => 'subcr'
  describe_valid_column '66% floating left',  :width => 66, :float => 'l', :yaml => 'c66l', :yaml_content => 'subcl'
  describe_valid_column '66% floating right', :width => 66, :float => 'r', :yaml => 'c66r', :yaml_content => 'subcr'
  describe_valid_column '38% floating right', :width => 38, :float => 'r', :yaml => 'c38r', :yaml_content => 'subcr'
  describe_valid_column '38% floating right', :width => 38, :float => 'r', :yaml => 'c38r', :yaml_content => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :yaml => 'c62r', :yaml_content => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :yaml => 'c62r', :yaml_content => 'subcr'
  describe_valid_column '100% not floating' , :width =>100, :float => nil, :yaml => nil, :yaml_content => 'subcolumns'

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

end
