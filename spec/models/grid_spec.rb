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

describe Grid do
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
  describe_valid_column '28% floating right', :width => 28, :float => 'r', :yaml => 'c28r', :yaml_content => 'subcr'
  describe_valid_column '28% floating right', :width => 28, :float => 'r', :yaml => 'c28r', :yaml_content => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :yaml => 'c62r', :yaml_content => 'subcr'
  describe_valid_column '62% floating right', :width => 62, :float => 'r', :yaml => 'c62r', :yaml_content => 'subcr'
end
