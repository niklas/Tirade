require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  fixtures :users

  describe "With Ajax" do
    
    describe "logging in with valid credentials" do

      def do_login
        post :create, :user_session => {:login => 'quentin', :password => 'test'}, :format => 'js'
      end

      it "should succeed" do
        do_login
        response.should be_success
      end

      it "should load dashboard into toolbox" do
        do_login
        response.body.should =~ /dashboard/i
      end
      
    end

  end

end
