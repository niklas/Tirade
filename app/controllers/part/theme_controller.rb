class Part::ThemeController < ApplicationController
  before_filter :fetch_part
  before_filter :fetch_theme
  feeds_toolbox_with :part, :except => :all

  def show
    @part.current_theme = @theme
    render_toolbox_action :show
  end

  def destroy
    if @part.remove_theme! @theme
      render_toolbox_action :destroyed
    else
      render_toolbox_action :failed_destroy
    end
  end

  private
  def fetch_part
    @model = @part = Part.find(params[:part_id])
  end

  def fetch_theme
    @theme = params[:id].to_s
  end
end