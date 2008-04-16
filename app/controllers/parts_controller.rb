class PartsController < ApplicationController
  protect_from_forgery :except => [:preview]
  # GET /parts
  # GET /parts.xml
  def index
    @parts = Part.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @parts }
    end
  end

  # GET /parts/1
  # GET /parts/1.xml
  def show
    @part = Part.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @part }
    end
  end

  # GET /parts/new
  # GET /parts/new.xml
  def new
    @part = Part.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @part }
    end
  end

  # GET /parts/1/edit
  def edit
    @part = Part.find(params[:id])
  end

  # POST /parts
  # POST /parts.xml
  def create
    @part = Part.new(params[:part])

    respond_to do |format|
      if @part.save
        flash[:notice] = 'Part was successfully created.'
        format.html { redirect_to(@part) }
        format.xml  { render :xml => @part, :status => :created, :location => @part }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @part.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /parts/1
  # PUT /parts/1.xml
  def update
    @part = Part.find(params[:id])

    respond_to do |format|
      if @part.update_attributes(params[:part])
        flash[:notice] = 'Part was successfully updated.'
        format.html { redirect_to(@part) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @part.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /parts/1
  # DELETE /parts/1.xml
  def destroy
    @part = Part.find(params[:id])
    @part.destroy

    respond_to do |format|
      format.html { redirect_to(parts_url) }
      format.xml  { head :ok }
    end
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
