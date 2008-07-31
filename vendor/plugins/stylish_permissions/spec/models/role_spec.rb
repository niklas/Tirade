require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  fixtures :all
  it do
    Role.should have_at_least(2).records
  end

  describe "Editor" do
    before do
      @editor = roles(:editor)
    end
    it "should be called 'Editor'" do
      @editor.name.should == 'Editor'
      @editor.short_name.should == 'editor'
    end

    it do
      @editor.should have_at_least(3).permissions
    end

    it "may manupulate pages" do
      Role.manipulators_for('pages').should include(@editor)
    end
  end

  describe "Designer" do
    before do
      @designer = roles(:designer)
    end
    it "should be called 'Designer'" do
      @designer.name.should == 'Designer'
      @designer.short_name.should == 'designer'
    end
    it do
      @designer.should have_at_least(3).permissions
    end
  end
end
