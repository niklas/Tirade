class WrapBlock < Liquid::Block                                             
  def initialize(tag_name, markup, tokens)
     super 
     @class = markup.downcase
  end

  def render(context)
    [
      %Q~<div class="#{@class}">~,
      render_all(@nodelist, context),
      %Q~</div>~
    ]
  end    
end
