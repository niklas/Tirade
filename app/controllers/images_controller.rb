class ImagesController < ApplicationController
  protect_from_forgery :only => [:create, :destroy]

  layout 'admin'
  in_place_edit_for :image, :title
  
  def index
    # TODO: Pagination
    @images = Image.find(:all, :order => 'created_at DESC')
    
  end
  
  def new
    @image = Image.new
  end
  
  def create
    @image = Image.new(params[:image])
    
    if @image.save
      redirect_to images_path
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    
    redirect_to(images_path)
  end
  
  # ===========
  # = Members =
  # ===========
  def set_image_title
    @image = Image.find(params[:id])
    @image.update_attribute :title, params[:value]
    respond_to do |format|
      format.html
      format.js do
        render :text => @image.title
      end
    end
  end
end
