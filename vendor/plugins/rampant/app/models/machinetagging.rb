class Machinetagging < ActiveRecord::Base
  belongs_to :machinetag, :counter_cache => true
  belongs_to :machinetaggable, :polymorphic => true
  belongs_to :user

  named_scope :for_user, lambda {|user_or_id|
    if user_or_id.is_a? Fixnum
      {:conditions => ['user_id = ?', user_or_id]}
    elsif user_or_id.is_a? String
      {:conditions => ['user_id = ?', user_or_id.to_i]}
    else
      {:conditions => ['user_id = ?', user_or_id.id]}
    end
  }
end
