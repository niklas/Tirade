require File.dirname(__FILE__) + '/../spec_helper'

describe PagesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the PageHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(PagesHelper)
  end
  
end

describe PagesHelper, ", rendering the main page" do
  fixtures :all
  before(:each) do
    Page.rebuild!
    Grid.rebuild!
    Content.rebuild!
    @page = pages(:main)
    stub!(:render).and_return('<p>fake render result</p>')
    @rendered = render_page(@page)
  end

  it "should not be blank" do
    @rendered.should_not be_blank
  end

  it "should have surrounding page div"
  it "should have surrounding div for first grid"
  it "should have surrounding div for second grid"
  it "should have content of first grid"
  it "should have content of second grid"

end
