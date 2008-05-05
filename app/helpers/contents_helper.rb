module ContentsHelper
  def field_partial_for(content)
    '/contents/content_fields'
  end

  def render_form_fields_for(theform)
    content = theform.object
    klass = content.class
    begin
      partial_name = "/contents/#{klass.to_s.underscore}_fields"
      render(:partial => partial_name, :object => theform)
    rescue ActionView::ActionViewError => e
      @errors ||= []
      @errors << e
      unless Content == klass
        klass = klass.superclass
        retry
      end
      raise "No fields partial found for #{content.class}" 
    end
  end
end
