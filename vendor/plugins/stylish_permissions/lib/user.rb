module StylishPermissions
  module User
    def self.included(base)
      base.has_many :roles, :through => :user_roles, :dependent => :destroy
      base.has_many :user_roles
      base.has_and_belongs_to_many :groups
    end
    # FIXME use first_name and last_name
    def full_name
      login
    end

    def permissions
      (
        roles.map {|r| r.permissions } +
        groups.map {|g| g.permissions }
      ).flatten.uniq
    end

    def permissions_names
      permissions.map { |perm| perm.name }
    end

    def roles_names
      roles.all.map {|r| r.name }
    end

    def roles_short_names
      roles.all.map {|r| r.short_name }
    end
  end
end
