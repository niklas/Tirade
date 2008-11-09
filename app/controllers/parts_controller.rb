class PartsController < ApplicationController
  feeds_toolbox_with :part
  layout 'admin'
  protect_from_forgery :except => [:preview]

  def index
    @models = @parts = Part.search(params[:search].andand[:term]).find(:all, :order => 'name ASC')
    render_toolbox_action :index
  end

  def after_update_toolbox_for_updated(page)
  end

  def preview
    @part = Part.find(params[:id])
    @part.attributes = params[:part]
    @content = Struct.new(:title, :body).new
    @content.title = 'some Title'
    @content.body = 'I want a Lollipop, Lollipop, Lollipop. It is so sweet!'
    respond_to do |wants|
      wants.js do
        render :update do |page|
          @part.template_binding = binding
          if @part.valid?
            local_assigns = @part.options
            page[:preview].replace_html @part.render(binding)
          else
            page[:preview].replace_html error_messages_for(:part)
          end
          page[:preview].visual_effect :highlight
        end
      end
    end
  end
end
