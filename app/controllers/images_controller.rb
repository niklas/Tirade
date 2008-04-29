class ImagesController < ApplicationController
  layout 'admin'
  
  def index
    # TODO: Pagination
    @images = Image.find(:all, :order => 'created_at DESC')
    
  end
  
  def new
    
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
end
