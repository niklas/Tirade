module ImagesHelper
  def add_image_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :upload_images, :partial => 'form_image', :object => Image.new
    end
  end
end
