class CreateMachineTags < ActiveRecord::Migration
  def self.up
    create_table :machinetags do |t|
      t.string :namespace, :limit => 128
      t.string :key, :limit => 128
      t.string :value, :limit => 1024
      t.integer :machinetaggings_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :machinetags, :namespace, :name => "index_mtags_on_namespace"
    add_index :machinetags, :key, :name => "index_mtags_on_key"
    add_index :machinetags, :value, :name => "index_mtags_on_value"
    add_index :machinetags, :machinetaggings_count, :name => "index_mtags_on_mtaggings_count"
  end

  def self.down
    drop_table :machinetags
    # TODO drop indices, too?
  end
end

