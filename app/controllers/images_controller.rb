class ImagesController < ManageResourceController::Base
  in_place_edit_for :image, :title
  skip_before_filter :login_required, :only => :custom

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
