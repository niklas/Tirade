# adds some methods to Models to set a #wanted_parent_id that gets applied after saving
module LazyNestedSet
  def wanted_parent_id
     @wanted_parent_id
  end

  def wanted_parent_id=(new_parent_id)
    @wanted_parent_id = new_parent_id
  end

  def move_to_parent_if_wanted
    if !wanted_parent_id.blank? && (new_parent = self.class.table_name.classify.constantize.find_by_id(wanted_parent_id))
      if new_parent.id != self.parent_id
        transaction do
          self.move_to_child_of new_parent
          self.after_move if self.respond_to?(:after_move)
        end
      end
    end
    @wanted_parent_id = nil
  end

  def self.included(base)
    base.after_save :move_to_parent_if_wanted
  end
end
