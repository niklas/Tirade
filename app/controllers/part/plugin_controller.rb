class Part::PluginController < ManageResourceController::Base
  # TODO spec and make work again
  before_filter :fetch_part
  before_filter :fetch_plugin

  def show
    @part.current_plugin = @plugin
    render_toolbox_action :show
  end

  # TODO refresh page
  def destroy
    if @part.remove_plugin! @plugin
      render_toolbox_action :destroyed
    else
      render_toolbox_action :failed_destroy
    end
  end

  private
  def fetch_part
    @model = @part = Part.find(params[:part_id])
  end

  def fetch_plugin
    @plugin = params[:id].to_s
  end
end
