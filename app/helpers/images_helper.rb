module ImagesHelper
  def add_image_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :upload_images, :partial => 'form_image', :object => Image.new
    end
  end

  def scaled_image_tag(record_with_image,geom,opts={})
    return '' unless record_with_image
    image = record_with_image.is_a?(Image) ? record_with_image : record_with_image.image
    opts[:title] ||= image.title
    opts[:alt] ||= image.title
    image_tag(image.custom_thumbnail_url(geom),opts)
  end
end
