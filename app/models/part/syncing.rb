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
      globs.each do |pattern|
        Dir.glob(pattern).each do |path|
          part = build_from_path(path)
          if part.valid?
            part.save!
            created << part
          else
            logger.info("Part: could not create #{part.filename}: #{part.errors.full_messages.to_sentence}")
          end
        end
      end
    end
    created
  end

  def self.globs
    [PluginsGlob, ThemesGlob, BaseGlob]
  end

  def self.build_from_path(path)
    part = Part.new
    filename_without_extention = File.basename(path).sub(/\.#{extention}$/,'').sub(/^_/,'') 
    part.filename  = filename_without_extention
    part.name = filename_without_extention.titleize
    part.configuration = part.load_configuration_from(path)
    #unless ().blank?
    #  part.save
    #end
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
