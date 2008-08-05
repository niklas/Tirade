class ImagesController < ApplicationController
  protect_from_forgery :only => [:create, :destroy]

  layout 'admin'
  in_place_edit_for :image, :title
  feeds_toolbox_with :image
  
  def index
    # TODO: Pagination
    @models = @images = Image.search(params[:term]).find(:all, :order => 'created_at DESC')

    if params[:for_select]
      respond_to do |wants|
        wants.html
        wants.js { render :action => 'search_results'}
      end
    else
      render_toolbox_action :index
    end
  end

  # TODO append .js in multipartform
  def create
    @image = Image.new(params[:image])

    
    if @image.save
      @models = @images = [@image] + @image.multiple_images
      the_action = @images.length > 1 ? :index : :show
      if params[:iframe_remote]
        # successful, from iframe => show created image(s)
        responds_to_parent do
          render_toolbox_action the_action
        end
      else
        # successful, normal cases
        respond_to do |wants|
          wants.html
          wants.js { render_toolbox_action the_action }
        end
      end
    else
      if params[:iframe_remote]
        # unsuccessful from iframe
        responds_to_parent do
          render_toolbox_action :new
        end
      else
        respond_to do |wants|
          wants.html
          wants.js { render_toolbox_action :new }
        end
     end
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
