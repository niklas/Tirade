class Part < ActiveRecord::Base
  BlacklistesFileNames = %w(
    exit
    filename
    name
  )
  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_format_of :filename, :with => /\A[\w_]+\Z/
  validates_exclusion_of :filename, :in => BlacklistesFileNames
  def self.sync_from_filesystem
    created = []
    [BaseGlob, ThemesGlob].each do |pattern|
      Dir.glob(pattern).each do |filename|
        filename_without_extention = File.basename(filename).sub(extention,'').sub(/^_/,'')
        unless find_by_filename(filename_without_extention)
          created << create!(:filename => filename_without_extention)
        end
      end
    end
    created
  end

  def self.sync!
    find(:all).each do |part|
      part.sync_configuration!
    end
    sync_from_filesystem
  end

  # Saves the needed attributes to a .yml file or reads them in from there
  def sync_configuration!
    load_yml_if_needed!
    save_yml_if_needed!
  end

  # TODO: Where is #fullpath needed?
  #alias_method :fullpath, :active_liquid_path

  # TODO: Where is #existing_fullpath needed?
  #alias_method :existing_fullpath, :active_liquid_path

  def absolute_partial_name
    '/' + File.join('parts',PartsDir,filename) + extention
  end
  def partial_name
    File.join(PartsDir,filename)
  end

  def filename_with_extention
    real_filename.ends_with?(extention) ? real_filename : (real_filename + extention)
  end

  def real_filename
    '_' + filename
  end

  def real_filename=(real)
    self.filename = real.gsub(/^_*/,'')
  end

end
