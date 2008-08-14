class CreateMachineTags < ActiveRecord::Migration
  def self.up
    create_table :machinetags do |t|
      t.string :name, :limit => 128
      # TODO split names into namespace:"predicate"
      # t.string :predicate, :limit => 1024
      t.integer :machinetaggings_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :machinetags, :name, :name => "index_mtags_on_name"
    add_index :machinetags, :machinetaggings_count, :name => "index_mtags_on_mtaggings_count"
  end

  def self.down
    drop_table :machinetags
    # TODO drop indices, too?
  end
end

