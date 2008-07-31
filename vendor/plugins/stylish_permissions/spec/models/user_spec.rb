require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :all
  it "should have 2 users" do
    User.should have(2).records
  end

  describe 'Aaron' do
    before do
      @aaron = users(:aaron)
    end
    it "should have >= 1 role" do
      @aaron.should have_at_least(1).role
    end
    it "should be a designer" do
      @aaron.roles.should include(roles(:designer))
    end

    it "should have a shortcut to the role names" do
      @aaron.roles_short_names.should include("designer")
    end

    describe "his permission names" do
      before do
        @per_names = @aaron.permissions_names
      end
      it "should name the Designer's permissions" do
        @per_names.should include('parts/edit')
        @per_names.should include('parts/update')
        @per_names.should include('grids/order_renderings')
      end
      it "should not name the Editor's permissions" do
        @per_names.should_not include('pages/edit')
        @per_names.should_not include('pages/update')
      end
    end
  end

  describe 'Quentin' do
    before do
      @quentin = users(:quentin)
    end
    it "should have >= 2 roles" do
      @quentin.should have_at_least(2).roles
    end
    it "should be a designer" do
      @quentin.roles.should include(roles(:designer))
    end
    it "should be an editor" do
      @quentin.roles.should include(roles(:editor))
    end
    it "should have a shortcut to the role names" do
      names = @quentin.roles_short_names
      names.should include("designer")
      names.should include("editor")
    end

    describe "his permission names" do
      before do
        @per_names = @quentin.permissions_names
      end
      it "should name the Designer's permissions" do
        @per_names.should include('parts/edit')
        @per_names.should include('parts/update')
        @per_names.should include('grids/order_renderings')
      end
      it "should name the Editor's permissions" do
        @per_names.should include('pages/edit')
        @per_names.should include('pages/update')
        @per_names.should include('grids/order_renderings')
      end
    end
  end
end
