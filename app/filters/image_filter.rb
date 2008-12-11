module ImageFilter
  def scale(image,geom='50x50')
    image.url = image.url.gsub(/original/, %Q~custom/#{geom}~)
    image
  end

  def to_image(image)
    %Q[<img src="#{image.url}" alt="#{image.title}" title="#{image.title}" />]
  end
end
