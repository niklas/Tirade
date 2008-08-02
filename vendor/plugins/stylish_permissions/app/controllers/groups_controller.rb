class GroupsController < ApplicationController
  before_filter :fix_hbtm_ids, :only => [:update]
  feeds_toolbox_with :group

  private
  def fix_hbtm_ids
    params[:group][:user_ids] ||= [] if (params[:group] ||= {})
    params[:group][:role_ids] ||= [] if (params[:group] ||= {})
  end
end
