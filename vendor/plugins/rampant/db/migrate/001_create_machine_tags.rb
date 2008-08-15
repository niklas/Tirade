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
    create_table :machinetaggings do |t|
      t.integer :machinetag_id
      t.integer :machinetaggable_id
      t.string :machinetaggable_type, :limit => 32
      t.integer :user_id

      t.timestamps
    end

    add_index :machinetaggings, [:machinetag_id, :machinetaggable_type], :name => "index_mtaggings_on_mtag_id_and_mtaggable_type"
    add_index :machinetaggings, [:user_id, :machinetag_id, :machinetaggable_type], :name => "index_mtaggings_on_user_id_and_mtag_id_and_mtaggable_type"
    add_index :machinetaggings, [:machinetaggable_id, :machinetaggable_type], :name => "index_mtaggings_on_mtaggable_id_and_mtaggable_type"
    add_index :machinetaggings, [:user_id, :machinetaggable_id, :machinetaggable_type], :name => "index_mtaggings_on_user_id_and_mtaggable_id_and_mtaggable_type"
  end

  def self.down
    drop_table :machinetaggings
    drop_table :machinetags
  end
end

