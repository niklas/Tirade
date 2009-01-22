class Part::ThemeController < ApplicationController
  before_filter :fetch_part
  before_filter :fetch_theme
  feeds_toolbox_with :part, :except => :all

  def show
    @part.current_theme = @theme
    render_toolbox_action :show
  end

  def delete
    @part.current_theme = @theme
  end

  private
  def fetch_part
    @part = Part.find(params[:part_id])
  end

  def fetch_theme
    @theme= params[:id].to_s
  end
end
