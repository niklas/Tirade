module Rendering::GridHelper
  def grid_tree_list_from(node, &block)
    children = node.visible_children
    content_tag(:span,block.call(node)) + 
    if children.empty?
      ''
    else
      content_tag(
        :ul,
        children.collect do |child|
          content_tag(
            :li,
            grid_tree_list_from(child,&block)
          )
        end.join(' ')
      )
    end
  end
end
