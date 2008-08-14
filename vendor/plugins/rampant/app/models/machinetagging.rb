class Machinetagging < ActiveRecord::Base
  belongs_to :machinetag, :counter_cache => true
  belongs_to :machinetaggable, :polymorphic => true
  belongs_to :user
end