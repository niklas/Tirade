module InterfaceHelper
  # Opens up a Wrapper for an +accordion+ with 1 or more +acction_item+s. Use it as a block
  # with <% %> tags around it (no '=')
  #   <% accorion do %>
  #     <% accordion_item "One" do %>
  #       One Content Here
  #     <% end %>
  #     <% accordion_item "Two" do %>
  #       Two Content Here
  #     <% end %>
  #   <% end %>
  def accordion(opts={}, &block)
    dom = opts.delete(:id) || 'accordion'
    concat content_tag( :div, capture(&block), :id => dom, :class => 'accordion'), block.binding
  end

  def accordion_item(title="Accordion Item", opts={}, &block)
    concat content_tag(:h3,title, :class => 'accordion_toggle'), block.binding
    concat content_tag(:div,capture(&block), :class => 'accordion_content'), block.binding
  end

  # Creates a bar of links
  #    <% links do %>
  #      <li><%= link_to "Home", root_url %></li>
  #      <%= li_link_to "Home", root_url %>
  #    <% end %>
  def links(&block)
    concat content_tag(:ul,capture(&block), :class => 'linkbar'), block.binding
  end

  def li_link_to(name, options = {}, html_options = nil)
    content_tag(:li,link_to(name,options,html_options))
  end

  def li_link_to_remote(name, options = {}, html_options = nil)
    content_tag(:li,link_to_remote(name,options,html_options))
  end
end
