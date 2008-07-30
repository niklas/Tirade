class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :roles
  belongs_to :super_group,
       :class_name => 'Group',
       :foreign_key => 'group_id'
  has_many :sub_groups,
     :class_name => 'Group',
     :foreign_key => 'group_id'
    # Return the permissions of this group and all the permissions of a super group
  # Since cycles can occur, we do a traversal of the permissions, instead of
  # just getting the group permissions and all super group permissions recusively.
  def permissions
    traverse_permissions(self)
  end

  # Traverse the path of super groups for permissions.
  # In case we find ourselfs, we stop. This is different from the
  # cycles?() below, since there can only be one super group. If you
  # imagine super groups above sub groups, traverse_permissions() travels up
  # the tree, while cycles?() travels down. The group that is passed in
  # is the group from which we start traversing groups.
  def traverse_permissions(group)
    group_permissions = roles.map{|r| r.permissions}
    if super_group && super_group != group then
      group_permissions += super_group.traverse_permissions
    end
    group_permissions.flatten.compact
  end

  # Check for cycles in groups. This method uses an array to store all
  # groups in a group graph. If the provided group is found in the
  # return array, this means that the group was found in it's own tree
  # and thus there is a cycle.
  def cycles?
    @group_ary = []
    get_groups(self)
    @group_ary.include?(self)
  end

private

  # This method recursively creates an array of groups in a group tree.
  # It stops when the group was already found in the tree. This
  # indicates at least one cycle. We don't bother though. Other methods
  # check if the object requested is part of a cycle. Since we travel
  # down the tree we check all subgroups.
  def get_groups(group)
    group.sub_groups.each do |subgroup|
      if @group_ary.include?(subgroup) then
        return
      else
        @group_ary << subgroup
        get_groups(subgroup)
      end
    end
  end
end
