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


  def link(content, title=nil)
    title ||= content.title
    url = []
    if content.respond_to?(:slug)
      url << @context['page'].andand.url
      url << content.slug 
    else
    end
    if url.empty?
      %Q~<a href="#{content}">#{title}</a>~
    else
      %Q~<a href="/#{url.join('/')}">#{title}</a>~
    end
  end

  def link_tag(title,url)
    %Q~<a href="#{url}">#{title}</a>~
  end

  def relative_link(content, parent)
    if page = @context['page']
      link content, "#{page.slug}/#{parent.slug}"
    else
      link content, parent.slug
    end
  end

  def link_to_page(page, title=nil)
    title ||= page.title
    %Q~<a href="/#{I18n.locale}/#{page.url}">#{title}</a>~
  end

end
