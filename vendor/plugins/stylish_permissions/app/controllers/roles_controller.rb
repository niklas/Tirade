class RolesController < ApplicationController
  before_filter :fetch_role, :only => [:show, :edit, :update]
  def index
    @roles = Role.find :all
  end

  def show
  end

  def edit
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "Role #{@role.id} created" 
      render :action => 'show'
    else
      flash[:notice] = "Creating Role #{@role.id} failed" 
      render :action => 'new'
    end
  end

  def update
    params[:role][:permission_ids] ||= []
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role #{@role.id} updated" 
      render :action => 'show'
    else
      flash[:notice] = "Updating Role #{@role.id} failed" 
      render :action => 'edit'
    end
  end

  private
  def fetch_role
    @role = Role.find params[:id]
  end
end
