class Paperclipping < ActiveRecord::Base
  belongs_to :asset
  belongs_to :content, :polymorphic => true
end
