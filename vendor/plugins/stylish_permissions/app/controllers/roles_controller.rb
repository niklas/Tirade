class RolesController < ManageResourceController::Base
  # TODO move into model
  before_filter :fix_hbtm_ids, :only => [:update]

  private
  def fix_hbtm_ids
    params[:role][:permission_ids] ||= [] if (params[:role] ||= {})
  end
end
