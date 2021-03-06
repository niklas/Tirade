# == Schema Information
# Schema version: 20090809211822
#
# Table name: user_groups
#
#  id         :integer         not null, primary key
#  name       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users

  validates_presence_of :name

  default_scope :order => 'name'

  def title
    name
  end

  #extend Lockdown::Helper

  # FIXME make work again - if we extend wtih Lockdown::Helper it is autoloaded to early and includes it twice in ActionView::Base,
  # thus hiding all links
  def self.find_by_symbolic_name!(sym)
    name = string_name(sym)
    find_by_name!( name )
  end
  
	def all_users
		User.find_by_sql <<-SQL
			select users.* 
			from users, user_groups_users
			where users.id = user_groups_users.user_id 
			and user_groups_users.user_group_id = #{self.id}
    SQL
	end
end
