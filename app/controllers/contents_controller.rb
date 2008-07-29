class ContentsController < ApplicationController
  layout 'admin'
  before_filter :which_content_type, :only => [:create, :new]
  # GET /contents
  # GET /contents.xml
  def index
    @contents = Content.browse(params)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
      format.js
    end
  end

  # GET /contents/1
  # GET /contents/1.xml
  def show
    @content = Content.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content }
      format.js
    end
  end

  # GET /contents/new
  # GET /contents/new.xml
  def new
    @content = @klass.new(params[:content])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content }
      format.js
    end
  end

  # GET /contents/1/edit
  def edit
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.js
    end
  end

  # POST /contents
  # POST /contents.xml
  def create
    @content = @klass.new(params[:content])

    respond_to do |format|
      if @content.save
        flash[:notice] = 'Content was successfully created.'
        format.html { redirect_to(content_path(@content)) }
        format.xml  { render :xml => @content, :status => :created, :location => @content }
        format.js  { render :template => '/contents/show' }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
        format.js { render :template=> "/contents/new" }
      end
    end
  end

  # PUT /contents/1
  # PUT /contents/1.xml
  def update
    @content = Content.find(params[:id])

    respond_to do |format|
      if @content.update_attributes(params[:content])
        flash[:notice] = 'Content was successfully updated.'
        format.html { redirect_to(content_path(@content)) }
        format.xml  { head :ok }
        format.js do
          @rendering = Rendering.find(params[:rendering_id])
          render :template => '/renderings/show'
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content.errors, :status => :unprocessable_entity }
        format.js do
          @rendering = Rendering.find(params[:rendering_id])
          render :template => '/rendering/content/edit'
        end
      end
    end
  end

  # DELETE /contents/1
  # DELETE /contents/1.xml
  def destroy
    @content = Content.find(params[:id])
    @content.destroy

    respond_to do |format|
      format.html { redirect_to(contents_url) }
      format.xml  { head :ok }
    end
  end

  private

  def which_content_type
    @klass = params[:content].andand[:type].andand.constantize || Document
    @klass < Content ? @klass : Document
  end
end
