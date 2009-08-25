# == Schema Information
# Schema version: 20090809211822
#
# Table name: users
#
#  id                        :integer         not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  remember_token            :string(255)     
#  crypted_password          :string(128)     default(""), not null
#  password_reset_code       :string(40)      
#  salt                      :string(128)     default(""), not null
#  activation_code           :string(40)      
#  remember_token_expires_at :datetime        
#  activated_at              :datetime        
#  deleted_at                :datetime        
#  state                     :string(255)     default("passive")
#  created_at                :datetime        
#  updated_at                :datetime        
#  is_admin                  :boolean         
#  persistence_token         :string(255)     
#

class User < ActiveRecord::Base

  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
  end

  attr_accessible :login, :email, :password, :password_confirmation

  has_and_belongs_to_many :user_groups, :uniq => true

  # ===================
  # = Role Management =
  # ===================
  # FIXME: Role Management is just stub methods, need to be implemented
  
  def may?(*args)
    true
  end

  def title
    login
  end

  def full_name
    login
  end
  
end
