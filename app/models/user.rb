# == Schema Information
# Schema version: 2
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
end
