class RecordFrameRenderer < FrameRenderer
  attr_reader :record
  def initialize(record, template, opts={})
    @record = record
    super(template, opts)
  end
  def meta
    if record.new_record?
      super
    else
      super.merge({
        :id => record.id
      })
    end
  end

  def title
    if record.new_record?
      "new #{record.class_name}"
    else
      record_title
    end
  end

  def record_title
    (record.title || "#{record.class_name} ##{record.id}")
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
      :object => record,
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
end

