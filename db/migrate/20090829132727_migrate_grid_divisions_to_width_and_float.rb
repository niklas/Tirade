class MigrateGridDivisionsToWidthAndFloat < ActiveRecord::Migration
  def self.up
    Grid.transaction do
      Grid.all.each do |grid|
        grid.update_attributes!(:division => grid[:division]) unless grid[:division].blank?
      end
    end
  end

  def self.down
    # don't care.. was to confusing
  end
end
