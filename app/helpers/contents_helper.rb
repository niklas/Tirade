module ContentsHelper
  def field_partial_for(content)
    '/contents/content_fields'
  end

  def render_form_fields_for(theform)
    content = theform.object
    klass = content.class
    begin
      partial_name = "/contents/#{klass.to_s.underscore}_fields"
      logger.debug("render_form_fields_for: trying partial '#{partial_name}'")
      render(:partial => partial_name, :object => theform)
    rescue ActionView::ActionViewError => e
      @errors ||= []
      @errors << e
      logger.debug("render_form_fields_for: failed: #{e.message}")
      unless Content == klass
        klass = klass.superclass
        retry
      end
      raise "No fields partial found for #{content.class}" 
    end
  end

  def render_attributes_for(content)
    klass = content.class
    begin
      partial_name = "/contents/#{klass.to_s.underscore}_attributes"
      logger.debug("render_attributes_for: trying partial '#{partial_name}'")
      render(:partial => partial_name, :object => content)
    rescue ActionView::ActionViewError => e
      @errors ||= []
      @errors << e
      logger.debug("render_form_fields_for: failed: #{e.message}")
      unless Content == klass
        klass = klass.superclass
        retry
      else
        render(:partial => '/contents/attributes', :object => content)
      end
    end
  end
end
