class User < ActiveRecord::Base
  has_many :roles, :through => :user_roles, :dependent => :destroy
  has_many :user_roles
  has_and_belongs_to_many :groups

  def permissions
    (
      roles.map {|r| r.permissions } +
      groups.map {|g| g.permissions }
    ).flatten.uniq
  end

  def permissions_names
    permissions.map { |perm| perm.name }
  end

  def roles_short_names
    roles.all.map {|r| r.short_name }
  end
end
