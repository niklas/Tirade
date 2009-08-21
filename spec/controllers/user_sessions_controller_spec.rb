require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  fixtures :users
  integrate_views

  describe "With Ajax" do
    
    describe "logging in with valid credentials" do

      def do_login
        post :create, :user_session => {:login => 'quentin', :password => 'test'}, :format => 'js'
      end

      it "should succeed" do
        do_login
        response.should be_success
      end

      it "should refresh the dashboard" do
        do_login
        response.body.should include(%Q[Toolbox.frames(":resource(user_session/show)").refresh()])
      end

      it "should remove the login frame" do
        do_login
        response.body.should include(%Q[Toolbox.frames(":resource(user_session/new)").remove()])
      end

      it "should scroll the toolbox to the first frame (aka dashboard)" do
        do_login
        response.body.should include(%Q[Toolbox.goto(0)])
        
      end
      
    end

  end

  describe "not logged in" do
    
    describe "requesting update of status" do
      def do_request
        get :show, :format => 'js'
      end

      it "should update the loginout box with a link to log in" do
        do_request
        #response.body.should replace_element('body > div.loginout').with_tag('div.loginout') do
        #  with_tag 'a.login'
        #end
        response.body.should replace_element('body > div.loginout') do |html|
          html.should have_tag('div.loginout') do
            with_tag('a.login')
          end
        end
      end
    end
  end

end
