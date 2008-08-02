class RolesController < ApplicationController
  before_filter :fix_hbtm_ids, :only => [:update]
  feeds_toolbox_with :role

  private
  def fix_hbtm_ids
    params[:role][:permission_ids] ||= [] if (params[:role] ||= {})
  end
end
