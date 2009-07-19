class GroupsController < ManageResourceController::Base
  # TODO move into model
  before_filter :fix_hbtm_ids, :only => [:update]

  private
  def fix_hbtm_ids
    params[:group][:user_ids] ||= [] if (params[:group] ||= {})
    params[:group][:role_ids] ||= [] if (params[:group] ||= {})
  end
end
