ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.string :name
    t.integer :age
  end
  
  create_table :pictures, :force => true do |t|
    t.string :title
    t.references :pictureable, :polymorphic => true
  end
end
