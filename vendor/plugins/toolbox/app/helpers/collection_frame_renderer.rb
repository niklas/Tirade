class CollectionFrameRenderer < FrameRenderer
  alias_method :collection, :thingy
  def meta
    super.merge({
      :title => template.human_name.pluralize,
      :resource_name => template.resource_name
    })
  end
  def render_options
    super.merge({
      :locals => collection ? {
        template.resource_name.pluralize.to_sym => collection
      } : nil
    })
  end
  def default_partial
    'list'
  end
  def css
    css = super
    css << 'index'
    css << collection.first.resource_name unless collection.empty?
    css
  end

  def links
    [
      template.link_to_new(template.resource_name.classify.constantize)
    ]
  end
end
