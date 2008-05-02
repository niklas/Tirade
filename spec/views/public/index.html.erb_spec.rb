require File.dirname(__FILE__) + '/../../spec_helper'

describe "/public/index" do
  fixtures :all

  describe 'with path "/"' do
    before(:each) do
      assigns[:page] = pages(:main)
      render 'public/index'
    end
    it "should succeed" do
      response.should be_success
    end
    it "should least render a div" do
      response.body.should have_tag('div')
    end
    it "should render the grid layout" do
      response.body.should have_tag('div#doc') do
        with_tag('div.grid.yui-g') do
          have_tag('div.first.grid.yui-u')
          have_tag('div.grid.yui-u')
        end
      end
    end
    it "should render the whole page completely" do
      response.body.should have_tag('div#doc') do
        with_tag('div.grid.yui-g') do
          with_tag('div.first.grid.yui-u') do
            with_tag('div.rendering') do
              with_tag('h2', 'Welcome')
              with_tag('p', /big hug/)
            end
          end
          with_tag('div.first.grid + div.grid.yui-u') do
            with_tag('div.rendering') do
              with_tag('h2','Introduction')
              with_tag('p',/Tirade is a CMS/)
            end
          end
        end
      end
    end
  end
end
