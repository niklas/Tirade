# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  # just a placeholder for translations (localisation plugin)
  def _(phrase)
    phrase
  end

  def user_roles_classes
    current_user.andand.roles_names.collect {|r| "role_#{r}"}.join(' ') || ''
  end
end
