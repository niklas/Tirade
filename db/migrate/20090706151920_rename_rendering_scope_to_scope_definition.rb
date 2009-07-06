class RenameRenderingScopeToScopeDefinition < ActiveRecord::Migration
  def self.up
    rename_column :renderings, :scope, :scope_definition
  end

  def self.down
    rename_column :renderings, :scope_definition, :scope
  end
end
