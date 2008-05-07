class Picture < ActiveRecord::Base
  belongs_to :pictureable, :polymorphic => true
end