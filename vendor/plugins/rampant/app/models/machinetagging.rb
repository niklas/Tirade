class Machinetagging < ActiveRecord::Base
  belongs_to :machinetag, :counter_cache => true
  belongs_to :machinetaggable, :polymorphic => true
  belongs_to :user

  validates_uniqueness_of :machinetaggable_id, :scope => [:machinetaggable_type, :machinetag_id]

  named_scope :for_user, lambda {|user_or_id|
    if user_or_id.is_a? Fixnum
      {:conditions => ['user_id = ?', user_or_id]}
    elsif user_or_id.is_a? String
      {:conditions => ['user_id = ?', user_or_id.to_i]}
    else
      {:conditions => ['user_id = ?', user_or_id.id]}
    end
  }
  named_scope :without_auto, {:conditions => ['machinetags.namespace != ?', 'auto'], :include => :machinetag}
  named_scope :auto, {:conditions => ['machinetags.namespace = ?', 'auto'], :include => :machinetag}
end
