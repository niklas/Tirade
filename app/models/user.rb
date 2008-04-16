# == Schema Information
# Schema version: 4
#
# Table name: users
#
#  id            :integer         not null, primary key
#  name          :string(255)     
#  password_hash :string(40)      
#  password_salt :string(40)      
#  verified_at   :datetime        
#  email         :string(255)     
#  remember_me   :string(40)      
#  created_at    :datetime        
#  updated_at    :datetime        
#

class User < ActiveRecord::Base
  acts_as_authenticated_user

  def username_field
    'name'
  end

  # permission stuff, hobo like
  # now it is just a stub
  def may?(*args)
    true
  end
  def is_admin?
    true
  end

  # The names of all roles the User has
  def roles_names
    %w(admin)
  end
end
