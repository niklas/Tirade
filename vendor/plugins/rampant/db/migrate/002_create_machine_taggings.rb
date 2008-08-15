class CreateMachineTaggings < ActiveRecord::Migration
  # FIXME the second migration does not get executed. nobody knows why
  # have put the following stuff into CreateMachineTags
#  def self.up
#    create_table :machinetaggings do |t|
#      t.integer :machinetag_id
#      t.integer :machinetaggable_id
#      t.string :machinetaggable_type, :limit => 32
#      t.integer :user_id
#
#      t.timestamps
#    end
#
#    add_index :machinetaggings, [:machinetag_id, :machinetaggable_type], :name => "index_mtaggings_on_mtag_id_and_mtaggable_type"
#    add_index :machinetaggings, [:user_id, :machinetag_id, :machinetaggable_type], :name => "index_mtaggings_on_user_id_and_mtag_id_and_mtaggable_type"
#    add_index :machinetaggings, [:machinetaggable_id, :machinetaggable_type], :name => "index_mtaggings_on_mtaggable_id_and_mtaggable_type"
#    add_index :machinetaggings, [:user_id, :machinetaggable_id, :machinetaggable_type], :name => "index_mtaggings_on_user_id_and_mtaggable_id_and_mtaggable_type"
#
#  end
#
#  def self.down
#    drop_table :machinetaggings
#  end
end

