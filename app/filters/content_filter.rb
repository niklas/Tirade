module ContentFilter
  # {{ obj | render: 'partial_name' }}
  def render(content,partial_name=Part::Default)
    if part = Part.find_by_filename(partial_name)
      part.render_with_content(content)
    else
      %Q~<div class="warning">Part '#{partial_name}' not found.</div>~
    end
  end
end
