class Picturization < ActiveRecord::Base
  belongs_to :pictureable, :polymorphic => true
  belongs_to :image
  acts_as_list :scope => :pictureable
end
