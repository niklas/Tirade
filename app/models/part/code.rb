class Part < ActiveRecord::Base
  def needs_to_write_code?
    return false if @liquid.blank?
    ap = active_path
    if !ap.blank? && File.file?(ap) # our code differs from that in active_path
      @liquid != load_liquid_from(ap)
    else
      tp = theme_path
      (!File.exists?(tp) || File.mtime(tp) < (updated_at || Time.now) )
    end
  end

  private
  def save_code_if_needed!
    save_code! if !self.class.without_modification? && needs_to_write_code?
  end
  def save_code!
    return if code.blank?
    save_code_to! theme_path
  end

  def save_code_to!(path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path,'w') do |file|
      file.puts code
    end
  end

  def delete_code
    while path = active_path
      File.delete path
    end
  end
end

