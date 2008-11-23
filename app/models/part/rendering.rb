class Part < ActiveRecord::Base
  acts_as_renderer

  def render_with_content(content, assigns={})
    return '' if content.nil?
    render_to_string(:inline => self.rhtml, :locals => options_with_object(content).merge(assigns))
  end

  def render(assigns={})
    render_with_content(fake_content, assigns)
  end

  def options_with_object(obj)
    options.to_hash_with_defaults.merge({
      filename.to_sym => obj
    })
  end

  def fake_content
    (preferred_types.andand.first || "Document").constantize.sample
  end
end

