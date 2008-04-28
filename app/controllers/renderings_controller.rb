class RenderingsController < ApplicationController
  protect_from_forgery :only => []
  # GET /renderings
  # GET /renderings.xml
  def index
    respond_to do |wants|
      wants.js
    end
  end

  # GET /renderings/1
  # GET /renderings/1.xml
  def show
    @rendering = Rendering.find(params[:id])

    respond_to do |wants|
      wants.js
    end
  end

  # GET /renderings/new
  # GET /renderings/new.xml
  def new
    @rendering = Rendering.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rendering }
    end
  end

  # GET /renderings/1/edit
  def edit
    @rendering = Rendering.find(params[:id])
    respond_to do |wants|
      wants.js
    end
  end

  def duplicate
    @original_rendering = Rendering.find(params[:id])
    respond_to do |wants|
      if (@rendering = @original_rendering.clone) && @rendering.save
        wants.js {render :action => 'create'}
      end
    end
  end

  # POST /renderings
  # POST /renderings.xml
  def create
    @rendering = Rendering.new(params[:rendering])

    respond_to do |format|
      if @rendering.save
        flash[:notice] = 'Rendering was successfully created.'
        format.html { redirect_to(@rendering) }
        format.xml  { render :xml => @rendering, :status => :created, :location => @rendering }
        format.js 
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rendering.errors, :status => :unprocessable_entity }
        format.js   { render :action => "edit" }
      end
    end
  end

  # PUT /renderings/1
  def update
    @rendering = Rendering.find(params[:id])

    respond_to do |wants|
      wants.js do
        if @rendering.update_attributes(params[:rendering])
          flash[:notice] = 'Rendering was successfully updated.'
          render :action => 'show'
        else
          render :action => 'edit'
        end
      end
    end
  end

  # DELETE /renderings/1
  # DELETE /renderings/1.xml
  def destroy
    @rendering = Rendering.find(params[:id])
    @rendering.destroy

    respond_to do |format|
      format.html { redirect_to(renderings_url) }
      format.xml  { head :ok }
      format.js
    end
  end
  def preview
    @rendering = Rendering.find(params[:id])
    @rendering.attributes = params[:rendering] if params[:rendering]
    @part = @rendering.part
    @part.attributes = params[:part] if params[:part]
    @rendering.grid.attributes = params[:grid] if params[:grid]
    @rendering.content.attributes = params[:content] if params[:content]
    respond_to do |wants|
      wants.js
    end
  end
end
