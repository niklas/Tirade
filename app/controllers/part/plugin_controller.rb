class Part::PluginController < ApplicationController
  before_filter :fetch_part
  before_filter :fetch_plugin
  feeds_toolbox_with :part, :except => :all

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
