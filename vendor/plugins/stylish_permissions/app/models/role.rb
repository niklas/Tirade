class Role < ActiveRecord::Base
  # Associations
  has_many :users, :through => :user_roles, :dependent => :destroy
  has_many :user_roles

  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :groups
end
