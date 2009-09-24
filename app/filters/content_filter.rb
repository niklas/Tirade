module ContentFilter
  # {{ obj | render: 'partial_name' }}
  def render(content,partial_name=Part::Default)
    return '' if content.nil?
    if part = Part.find_by_filename(partial_name)
      part.render_with_content(
        content, 
        { :registers => @context.registers, :page => @context['page'] },
        @context.registers['rendering_context']
      ) 
    else
      %Q~<div class="warning">Part '#{partial_name}' not found.</div>~
    end
  end

  def yaml_debug(thingy)
    thingy.to_yaml
  end

  def title_link(content, base_url=nil)
    if base_url.blank?
      %Q~<a href="#{content.slug}">#{content.title}</a>~
    else
      %Q~<a href="/#{base_url}/#{content.slug}">#{content.title}</a>~
    end
  end

  def link_tag(title,url)
    %Q~<a href="#{url}">#{title}</a>~
  end

  def link(title, object_or_url)
    case object_or_url
    when Page
      link_to_page(object_or_url, title)
    when String
      link_tag(title, object_or_url)
    when nil
      link_tag(title, title)
    else
      link_tag(title, object_or_url.slug)
    end
  end

  def link_to_page(page, title=nil)
    title ||= page.title
    link_tag(title, "/#{I18n.locale}/#{page.url}")
  end

end
