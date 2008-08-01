module InterfaceHelper
  def accordion(opts={}, &block)
    dom = opts.delete(:id) || 'accordion'
    concat content_tag( :div, capture(&block), :id => dom, :class => 'accordion'), block.binding
  end

  def accordion_item(title="Accordion Item", opts={}, &block)
    concat content_tag(:h3,title, :class => 'accordion_toggle'), block.binding
    concat content_tag(:div,capture(&block), :class => 'accordion_content'), block.binding
  end
end
