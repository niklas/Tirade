# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ToolboxContent = 'toolbox_content'

  def controller_name
    controller.controller_name
  end

  # just a placeholder for translations (localisation plugin)
  def _(phrase)
    phrase
  end

  def content_given?(name) 
    ! instance_variable_get("@content_for_#{name}").nil?
  end 
  
  def flash_messages
    [:notice, :warning, :message, :error].map do |f|
      content_tag(:div, flash[f], :id => 'flash', :class => "#{f.to_s}") if flash[f]
    end.join
  end

  def warning_tag(text)
    content_tag(:div,text,{:class => 'warning'})
  end

  def context
    page.instance_variable_get("@context").instance_variable_get("@template")
  end

  def public_content_link(content,opts = {})
    content = Page.find_by_url(content) if content.is_a?(String)
    return "[link target not found]" unless content
    label = opts.delete(:label) || content.title
    url = [ public_content_path(content.url), opts.delete(:item_id)].compact.join('/')
    link_to(label,url,opts)
  end
  alias :public_page_link :public_content_link

  def public_item_link_with_scaled_image(item,geom)
    parent = item.parent
    public_page_link(parent.title, :item_id => item.id, :label => scaled_image_tag(item,geom))
  end

  # copied without shame from http://blog.vixiom.com/2007/06/05/rails-helper-for-swfobject/
  def swf_object(swf, id, width, height, flash_version, background_color, params = {}, vars = {}, create_div = false)
    # create div ?
    create_div ? output = "<div id=’#{id}‘>This website requires <a href=’http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&promoid=BIOW’ target=’_blank’>Flash player</a> #{flash_version} or higher.</div><script type=’text/javascript’>" : output = "<script type=’text/javascript’>"
    output << "var so = new SWFObject(’#{swf}‘, ‘#{id}‘, ‘#{width}‘, ‘#{height}‘, ‘#{flash_version}‘, ‘#{background_color}‘);"
    params.each  {|key, value| output << "so.addParam(’#{key}‘, ‘#{value}‘);"}
    vars.each    {|key, value| output << "so.addVariable(’#{key}‘, ‘#{value}‘);"}
    output << "so.write(’#{id}‘);"
    output << "</script>"
  end

end
