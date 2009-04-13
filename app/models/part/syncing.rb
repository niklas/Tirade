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
    Part.transaction do
      [PluginsGlob, ThemesGlob, BaseGlob].each do |pattern|
        Dir.glob(pattern).each do |path|
          part = create_from_path(path)
          if part.valid?
            created << part
          else
            logger.info("Part: could not create #{part.filename}: #{part.errors.full_messages.to_sentence}")
          end
        end
      end
    end
    created
  end

  def self.create_from_path(path)
    part = Part.new
    filename_without_extention = File.basename(path).sub(/\.#{extention}$/,'').sub(/^_/,'') 
    part.filename  = filename_without_extention
    part.name = filename_without_extention.titleize
    unless (part.configuration = part.load_configuration_from(path)).blank?
      part.save
    end
    part
  end

  def self.sync!
    find(:all).each do |part|
      part.sync_configuration!
    end
    sync_from_filesystem
  end


  # TODO: Where is #fullpath needed?
  #alias_method :fullpath, :active_liquid_path

  # TODO: Where is #existing_fullpath needed?
  #alias_method :existing_fullpath, :active_liquid_path


end
