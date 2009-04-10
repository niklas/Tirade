module Pages::LayoutHelper
  # Renders a hierarchical ul for the given object. will use #label to
  # create a fake anchor to hold the name
  def render_tree(squirrel, opts = {})
    tree = render_tree_node squirrel, opts
    content_tag(:ul,tree,:class => 'tree', :id => "#{dom_id squirrel}_tree")
  end

  # render_tree_node grid, :include => [:renderings]
  # render_tree_node page, :include => [:layout, :children, :renderings]
  # TODO use link_to
  def render_tree_node(squirrel, opts = {})
    children = detect_and_render_tree_node_children(squirrel, opts)

    active = opts[:active] == squirrel ? 'active' : ''
    content_tag(:li,
      content_tag(:a, label_for(squirrel), :class => 'label', :rel => squirrel.class.to_s.underscore) +
      (children.blank? ? '' : content_tag(:ul, children, :class => 'tree')),
      :class => "#{dom_class squirrel} #{dom_id squirrel} #{active}", :id => "#{dom_id squirrel}_item"
    )
  end

  def detect_and_render_tree_node_children(squirrel, opts={})
    case squirrel
    when Page
      render_tree_node_children squirrel, [:layout], opts
    when Grid
      render_tree_node_children squirrel, [:children, :renderings], opts
    when Rendering
      render_tree_node_children squirrel, [:content], opts
    else
      render_tree_node_children squirrel, [:children], opts
    end
  end

  def render_tree_node_children(squirrel, assocs, opts={})
    assocs.select do |assoc|
      squirrel.respond_to?(assoc)
    end.map do |assoc|
      items = squirrel.send(assoc)
      items = [items] unless items.respond_to?(:map)
      items.compact.map do |acorn|
        render_tree_node(acorn, opts)
      end.compact.join("\n")
    end.compact.join("\n")
  end

  def label_for(thingy)
    if thingy.respond_to?(:label)
      thingy.label
    elsif thingy.respond_to?(:title)
      thingy.title
    else
      dom_id(thingy).humanize
    end
  end

end
