module PublicHelper
  def dangling_id
    @dangling_id ||= (@controller.instance_variable_get('@item_id')) || 
      (@controller.params.andand[:path].andand.last.andand =~ /^(\d+)$/ ? $1.to_i : nil)
  end
end
