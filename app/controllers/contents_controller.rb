class ContentsController < ManageResourceController::Base

  def preview
    @content = Content.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          controller.preview_renderings_for(@content,page)
        end
      end
    end
  end

  def preview_renderings_for(content,page)
    content_attributes = params[:content]
    if @context_page
      Content.without_modification do
        @context_page.renderings.with_content(content).each do |rend|
          rend.content.attributes = content_attributes
          page.select("div.rendering##{dom_id(rend)}").replace_with(rend.render)
        end
      end
    end
  end
  private

end
