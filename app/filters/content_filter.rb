module ContentFilter
  # {{ obj | render: 'partial_name' }}
  def render(content,partial_name=Part::Default)
    return '' if content.nil?
    if part = Part.find_by_filename(partial_name)
      part.render_with_content(
        content, 
        @context.registers['rendering_context'], 
        :registers => @context.registers
      ) 
    else
      %Q~<div class="warning">Part '#{partial_name}' not found.</div>~
    end
  end

  def yaml_debug(thingy)
    thingy.to_yaml
  end

  def title_link(content, base_url=nil)
    base_url ||= content.table_name
    %Q~<a href="/#{base_url}/#{content.slug}">#{content.title}</a>~
  end
end
