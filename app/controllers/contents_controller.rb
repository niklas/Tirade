class ContentsController < ApplicationController
  before_filter :which_content_type, :only => [:create, :new]
  before_filter :fetch_rendering, :only => [:update]
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
      redirect_toolbox_to :action => 'show', :id => @content
    else
      flash[:notice] = "Could not create Content."
      render_toolbox_action :new
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
