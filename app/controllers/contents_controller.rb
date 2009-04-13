class ContentsController < ApplicationController
  before_filter :which_content_type, :only => [:create, :new]
  feeds_toolbox_with :content
  # GET /contents
  # GET /contents.xml
  def index
    @models = @contents = Content.browse(params)
    render_toolbox_action :index
  end

  # GET /contents/new
  # GET /contents/new.xml
  def new
    @model = @content = @klass.new(params[:content])
    render_toolbox_action :new
  end

  # POST /contents
  # POST /contents.xml
  def create
    @model = @content = @klass.new(params[:content])

    if @content.save
      flash[:notice] = "Content #{@content.id} was successfully created."
      render_toolbox_action :created
    else
      flash[:notice] = "Could not create Content."
      render_toolbox_action :failed_create
    end
  end

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

  def which_content_type
    @klass = params[:content].andand[:type].andand.constantize
    if @klass.nil? || @klass > Content
      @klass = nil
      render :action => 'select_type'
    else
      params[:content].andand.delete(:type)
    end
  end

  def fetch_rendering
    if request.xhr?
      @rendering = Rendering.find_by_id(params[:rendering_id])
    end
    true
  end
end
