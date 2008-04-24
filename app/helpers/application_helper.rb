# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ToolboxContent = 'toolbox_content'


  # just a placeholder for translations (localisation plugin)
  def _(phrase)
    phrase
  end

  def user_roles_classes
    unless current_user.nil?
      current_user.roles_names.collect {|r| "role_#{r}"}.join(' ') || ''
    end
  end
  
  def flash_messages
    [:notice, :warning, :message, :error].map do |f|
      content_tag(:div, flash[f], :id => 'flash', :class => "#{f.to_s}") if flash[f]
    end.join
  end

  def warning_tag(text)
    content_tag(:div,text,{:class => 'warning'})
  end
end
