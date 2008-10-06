class ToolboxController < ApplicationController
  layout 'public'
  def demo
    @demo = (params[:demo] || 1).to_i
  end
end
