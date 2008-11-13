class PartsController < ApplicationController
  feeds_toolbox_with :part
  layout 'admin'
  protect_from_forgery :except => [:preview]

  def index
    @models = @parts = Part.search(params[:search].andand[:term]).find(:all, :order => 'name ASC')
    render_toolbox_action :index
  end

  def after_update_toolbox_for_updated(page)
    preview_renderings_for(@part,page)
  end

  def preview
    @part = Part.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          controller.preview_renderings_for(@part,page)
        end
      end
    end
  end
  def preview_renderings_for(part,page)
    if thepage = Page.find_by_id(params[:context_page_id])
      Part.without_modification do
        if part.update_attributes(params[:part])
          page.select("div.errorExplanation").remove()
          thepage.renderings.with_part(part).each do |rend|
            page.select("div.rendering##{dom_id(rend)}").replace_with(rend.render)
          end
        else
          if rend = thepage.renderings.with_part(part).first 
            page.select("div.rendering##{dom_id(rend)}").html page.context.error_messages_for(:part, :object => part)
          else
            flash[:notice] = part.errors.full_messages
          end
        end
      end
    end
  end
end
