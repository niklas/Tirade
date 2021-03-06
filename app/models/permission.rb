# == Schema Information
# Schema version: 20090809211822
#
# Table name: permissions
#
#  id         :integer         not null, primary key
#  created_at :datetime        
#  updated_at :datetime        
#  name       :string(255)     
#

class Permission < ActiveRecord::Base
  has_and_belongs_to_many :user_groups

  
  default_scope :order => 'name'

  def title
    name
  end

	def all_users
		User.find_by_sql <<-SQL
			select users.* 
			from users, user_groups_users, permissions_user_groups
			where users.id = user_groups_users.user_id 
			and user_groups_users.user_group_id = permissions_user_groups.user_group_id
			and permissions_user_groups.permission_id = #{self.id}
		SQL
  end
end
