class RolesController < ApplicationController
  before_filter :fetch_role, :only => [:show, :edit, :update, :destroy]
  def index
    @roles = Role.find :all
    render :template => '/roles/index'
  end

  def show
    render :template => '/roles/show'
  end

  def edit
    render :template => '/roles/edit'
  end

  def new
    @role = Role.new
    render :template => '/roles/new'
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "Role #{@role.id} created" 
      redirect_to role_path(@role)
    else
      flash[:notice] = "Creating Role #{@role.id} failed" 
      render :template => '/roles/new'
    end
  end

  def update
    params[:role][:permission_ids] ||= [] if (params[:role] ||= {})
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role #{@role.id} updated" 
      redirect_to role_path(@role)
    else
      flash[:notice] = "Updating Role #{@role.id} failed" 
      render :template => '/roles/edit'
    end
  end

  def destroy
    if @role.destroy
      flash[:notice] = "Role #{@role.id} destroyed." 
      redirect_to roles_path
    else
      flash[:notice] = "Destroying Role #{@role.id} failed" 
      render :template => '/roles/show'
    end
  end

  private
  def fetch_role
    @role = Role.find params[:id]
  end
end
