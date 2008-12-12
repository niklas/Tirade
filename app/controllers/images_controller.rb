class ImagesController < ApplicationController
  protect_from_forgery :only => [:create, :destroy]

  layout 'admin'
  in_place_edit_for :image, :title
  feeds_toolbox_with :image
  
  def index
    # TODO: Pagination
    @models = @images = Image.search(params[:search].andand[:term]).find(:all, :order => 'created_at DESC')

    render_toolbox_action :index
  end

  # TODO append .js in multipartform
  def create
    @model = @image = Image.new(params[:image])

    
    if @image.save
      @models = @images = [@image] + @image.multiple_images
      @model = @image = @images.first
      responds_to_parent do
        render_toolbox_action :created
      end
    else
      responds_to_parent do
        render_toolbox_action :failed_create
      end
    end
  end

  def custom
    @image = Image.find(params[:id])
    @thumb = @image.scale_to(params[:geometry])
    @data = @thumb.make.read
    scaled_path = @image.image.path(%Q~custom/#{@thumb.target_geometry}~).gsub(%r~^#{RAILS_ROOT}/public~,'')
    self.class.cache_page @data, scaled_path
    send_data(@data, :disposition => 'inline', :type => 'image/jpg', :filename => @image.image_file_name)
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
