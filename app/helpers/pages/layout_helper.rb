module Pages::LayoutHelper
  # Renders a hierarchical ul for the given object. will use #label to
  # create a fake anchor to hold the name
  def render_tree(squirrel, opts = {})
    tree = case squirrel
           when Grid
             render_tree_node squirrel, opts
           end
    content_tag(:div,tree,:class => 'tree')
  end

  # TODO use link_to
  def render_tree_node(squirrel, opts = {})
    children = (opts[:include] || [:children]).map do |assoc|
      if squirrel.class.reflections[assoc] || squirrel.respond_to?(assoc)
        squirrel.send(assoc).map do |acorn|
          render_tree_node(acorn, opts)
        end.compact.join("\n")
      end
    end.compact.join("\n")

    active = opts[:active] == squirrel ? 'active' : ''
    content_tag(:li,
      content_tag(:a, label_for(squirrel), :class => 'label') +
      content_tag(:ul, children, :class => 'tree'),
      :class => "#{dom_class squirrel} #{dom_id squirrel} #{active}"
    )
  end

  def label_for(thingy)
    thingy.label
  end

end
