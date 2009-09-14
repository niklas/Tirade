class MovePluralFlagFromRenderingsToParts < ActiveRecord::Migration
  def self.up
    Rendering.transaction do
      Rendering.without_timestamps do
        Rendering.all.each do |rendering|
          if rendering.plural?
            rendering.part.andand.update_attribute!(:plural => true)
          end
        end
      end
    end
  end

  def self.down
    Rendering.transaction do
      Rendering.without_timestamps do
        Rendering.all.each do |rendering|
          if rendering.part.andand.plural?
            rendering.update_attribute!(:plural => true)
          end
        end
      end
    end
  end
end
