require File.dirname(__FILE__) + '/../spec_helper'

describe "Styled Permissions for Fixtures" do
  fixtures :all
  before(:each) do
    assigns[:roles] = Role.find(:all)
    render '/permissions.ncss'
  end

  it "should succeed" do
    response.should be_success
  end

  describe "its CSS" do
    before do
      @css = response.body
    end

    it "should (first) hide all forms" do
      @css.should hide_form('show')
      @css.should hide_form('edit')
      @css.should hide_form('update')
      @css.should hide_form('create')
      @css.should hide_form('destroy')
    end
    it "should (first) hide all links" do
      @css.should hide_link('show')
      @css.should hide_link('edit')
      @css.should hide_link('update')
      @css.should hide_link('create')
      @css.should hide_link('destroy')
    end

    it "should not hide nonsense" do
      @css.should_not hide_form('nonsense')
      @css.should_not hide_link('nonsense')
    end

    it "should show the Editor's permitted actions" do
      @css.should show_form('pages.edit')
      @css.should show_form('pages.update')
      @css.should show_form('grids.order_renderings')
    end

    it "should show the Designers's permitted actions" do
      @css.should show_form('parts.edit')
      @css.should show_form('parts.update')
      @css.should show_form('grids.order_renderings')
    end

  end
end
