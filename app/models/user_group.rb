class UserGroup < ActiveRecord::Base
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :users

  validates_presence_of :name

  extend Lockdown::Helper

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
