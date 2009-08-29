class MigrateGridDivisionsToWidthAndFloat < ActiveRecord::Migration
  def self.up
    Grid.transaction do
      Grid.all.each do |grid|
        grid.width ||= 100
        grid.division = grid[:division] unless grid[:division].blank?
        grid.save!
      end
    end
  end

  def self.down
    # don't care.. was to confusing
  end
end
