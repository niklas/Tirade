module ImageFilter
  def scale(image,geom='50x50')
    if image
      image.url = image.url.gsub(/original/, %Q~custom/#{geom}~)
    end
    image
  end

  def to_image(image)
    if image
      %Q[<img src="#{image.url}" alt="#{image.title}" title="#{image.title}" />]
    else
      %Q[]
    end
  end
end
