class CollectionFrameRenderer < FrameRenderer
  attr_reader :collection
  def initialize(collection, template, opts={})
    @collection = collection
    super(template, opts)
  end

  def title
    template.human_name.pluralize
  end

  def render_options
    super.merge({
      :object => collection,
      :locals => collection ? {
        template.resource_name.pluralize.to_sym => collection
      } : nil
    })
  end

  def partial
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
