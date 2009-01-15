class Part < ActiveRecord::Base

  # Theme stuff
  def use_theme=(useit)
    @use_theme = ![false, "false", "f", 0, "0", nil, ""].include?(useit)
  end
  def use_theme
    @use_theme
  end
  def use_theme?
    use_theme
  end

  # Does a counterpart of this file exists in the given theme, defaults to the current theme of the +active_controller+
  def in_theme?(theme_name=nil)
    File.exists? theme_path(theme_name)
  end

  def current_theme
    active_controller.andand.current_theme
  end

  def make_themable!(theme_name=nil)
    theme_name ||= current_theme
    self.use_theme = true
    if in_theme?(theme_name)
      return true
    else
      save_rhtml_in_theme!
    end
  end

  def remove_theme!(theme_name=nil)
    if theme_name ||= current_theme && in_theme?(theme_name)
      File.delete theme_path(theme_name)
    end
  end


end
