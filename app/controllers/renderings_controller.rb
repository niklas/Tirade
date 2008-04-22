class RenderingsController < ApplicationController
  # GET /renderings
  # GET /renderings.xml
  def index
    respond_to do |wants|
      wants.js do
        render :layout => false
      end
    end
  end

  # GET /renderings/1
  # GET /renderings/1.xml
  def show
    @rendering = Rendering.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rendering }
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
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rendering.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /renderings/1
  # PUT /renderings/1.xml
  def update
    @rendering = Rendering.find(params[:id])

    respond_to do |format|
      if @rendering.update_attributes(params[:rendering])
        flash[:notice] = 'Rendering was successfully updated.'
        format.html { redirect_to(@rendering) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rendering.errors, :status => :unprocessable_entity }
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
    end
  end
end
