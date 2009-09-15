class RecordFrameRenderer < FrameRenderer
  alias_method :record, :thingy
  def meta
    super.merge({
      :title => record.new_record? ? "new #{record.class_name}" : (record.title || "#{record.class_name} ##{record.id}"), 
      :resource_name => template.resource_name,
      :id => record.id
    })
  end

  def default_partial
    'show'
  end

  def inner
    tried_with_name = false
    begin
      super
    rescue ActionView::MissingTemplate => e
      if !tried_with_name # already tried_with_slash
        tried_with_name = true
        @partial = "/#{record.table_name}#{partial}"
        retry
      else
        raise e
      end
    end
  end

  def render_options
    super.merge({
      :locals => record ? {
        template.resource_name.to_sym => record
      } : nil
    })
  end

  def css
    css = super
    if record.respond_to?(:resource_name)
      css << 'new' if record.new_record?
      css << template.dom_id(record)
      css << record.resource_name
    end
    css
  end

  def links
    if action == 'show'
      [
        template.link_to_edit(record),
        template.link_to_destroy(record)
      ]
    else
      []
    end
  end
end

