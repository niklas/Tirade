class Part < ActiveRecord::Base
  after_save :save_code_if_needed!
  after_destroy :delete_code

  def needs_to_write_code?
    !@liquid.blank?
  end

  private
  def save_code_if_needed!
    save_code! if needs_to_write_code?
  end
  def save_code!
    return if code.blank?
    save_code_to! theme_path
  end

  def save_code_to!(path)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path,'w') do |file|
      file.puts code.gsub(/\r/,'')
    end
  end

  def delete_code
    File.delete theme_path if File.exists?(theme_path)
    File.delete stock_path if File.exists?(stock_path)
  end
end

