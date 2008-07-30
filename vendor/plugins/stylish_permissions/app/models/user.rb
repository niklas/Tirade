class User < ActiveRecord::Base
  has_many :roles, :through => :user_roles, :dependent => :destroy
  has_many :user_roles
  has_and_belongs_to_many :groups
end
