module AdminHelper
  def panel(title='A Panel',&block)
    head = if title.is_a?(Proc)
             content_tag(
               :h5,
               content_tag(:ul,capture(&title)),
               :class => 'with_tabs'
             )
           else
             content_tag(:h5,title)
           end
    concat content_tag(
      :div,
      head +
      content_tag(:ul,capture(&block)) ,
      :class => 'panel'
    ), block.binding
  end

  def panel_item(cont,html_opts={})
    content_tag(:li,cont,html_opts)
  end
end
