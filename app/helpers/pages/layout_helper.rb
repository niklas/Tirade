module Pages::LayoutHelper
  # Renders a hierarchical ul for the given object. will use #label to
  # create a fake anchor to hold the name
  def render_tree(squirrel, opts = {})
    tree = render_tree_node squirrel, opts
    content_tag(:ul,tree,:class => 'tree tree_root', :id => "#{dom_id squirrel}_tree")
  end

  # render_tree_node grid, :include => [:renderings]
  # render_tree_node page, :include => [:layout, :children, :renderings]
  # TODO use link_to
  def render_tree_node(squirrel, opts = {})
    children = detect_and_render_tree_node_children(squirrel, opts)

    active = opts[:active] == squirrel ? 'active' : ''
    content_tag(:li,
      content_tag(:div, dom_id(squirrel) + show_value(squirrel), :class => 'node')+
      (children.blank? ? '' : content_tag(:ul, children, :class => 'tree')),
      :class => "#{dom_class squirrel} #{dom_id squirrel} #{active}", :rel => dom_id(squirrel)
    )
  end

  def detect_and_render_tree_node_children(squirrel, opts={})
    case squirrel
    when Page
      render_tree_node_children squirrel, [squirrel.layout], opts
    when Grid
      render_tree_node_children squirrel, squirrel.children + squirrel.renderings.for_page(opts[:page]), opts
    when Rendering
      render_tree_node_children squirrel, [], opts
    else
      render_tree_node_children squirrel, [], opts
    end
  end

  def render_tree_node_children(squirrel, items, opts={})
    items.compact.map do |acorn|
      render_tree_node(acorn, opts)
    end.compact.join("\n")
  end

end
