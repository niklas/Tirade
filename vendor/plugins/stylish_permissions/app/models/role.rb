class Role < ActiveRecord::Base
  # Associations
  has_many :users, :through => :user_roles, :dependent => :destroy
  has_many :user_roles

  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :groups

  named_scope :manipulators_for, lambda { |res|
    {:include => [:permissions], :conditions => ["permissions.app_controller = ? AND permissions.app_method = ?",res, 'update']}
  }
  named_scope :that_may, lambda { |action, res|
    { :include => [:permissions], :conditions => ["permissions.app_controller = ? AND permissions.app_method = ?",res, action]}
  }
end
