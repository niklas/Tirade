module Tirade
  module Toolbox
    module Controller
      def self.included(base)
        base.extend(ClassMethods)
        base.helper :interface
        base.helper :toolbox
        base.class_eval do
          include(InstanceMethods)
        end
      end
      module ClassMethods
        def feeds_toolbox_with model_name, opts = {}
          model_name = model_name.to_s
          model_plural = model_name.pluralize
          model_class_name = model_name.classify
          model_class = model_class_name.constantize
          class_eval do
            before_filter :prepare_clipboard
            after_filter :add_created_model_to_clipboard, :only => [:create]
            rescue_from 'ActionView::TemplateError', :with => :rescue_error
            rescue_from 'ActionView::MissingTemplate', :with => :rescue_error
            before_filter :set_form_builder, :except => [:index,:show,:destroy]
            before_filter "fetch_#{model_name}", :only => [:show, :edit, :update, :destroy]
            define_method "fetch_#{model_name}" do
              instance_variable_set "@#{model_name}", model_class.find(params[:id])
              instance_variable_set '@model', instance_variable_get("@#{model_name}")
              instance_variable_set '@model_name', model_name
            end
            define_method :index do
              instance_variable_set "@#{model_plural}", 
                if model_class.acts_as?(:content)
                  model_class.
                    search(params[:search].andand[:term] || params[:term]).
                    order(params[:search].andand[:order] || params[:order] || 'id DESC').
                    paginate(:page => params[:page])
                else
                  model_class.
                    paginate(:page => params[:page])
                end
              instance_variable_set '@models', instance_variable_get("@#{model_plural}")
              render_toolbox_action :index
            end
            define_method :show do
              render_toolbox_action :show
            end
            define_method :edit do
              render_toolbox_action :edit
            end
            define_method :new do
              instance_variable_set "@#{model_name}", model_class.new(params[model_name])
              instance_variable_set '@model', instance_variable_get("@#{model_name}")
              render_toolbox_action :new
            end
            define_method :create do
              model = model_class.new(params[model_name])
              instance_variable_set '@model', model
              instance_variable_set "@#{model_name}", model
              if model.save
                flash[:notice] = "#{model_class_name} #{model.id} created."
                render_toolbox_action :created
              else
                flash[:notice] = "Creating #{model_class_name} failed."
                render_toolbox_action :failed_create
              end
            end
            define_method :update do
              model = instance_variable_get "@model"
              if model.update_attributes(params[model_name])
                flash[:notice] = "#{model_class_name} #{model.id} updated."
                render_toolbox_action :updated
              else
                flash[:notice] = "Updating #{model_class_name} #{model.id} failed."
                render_toolbox_action :failed_update
              end
            end
            define_method :destroy do
              model = instance_variable_get "@#{model_name}"
              if model.destroy
                flash[:notice] = "#{model_class_name} #{model.id} destroyed."
                render_toolbox_action :destroyed
              else
                flash[:notice] = "Destroying #{model_class_name} #{model.id} failed."
                render_toolbox_action :failed_destroy
              end
            end
          end
        end
      end
    end
    module InstanceMethods
      def redirect_toolbox_to args
        raise "this is depricated"
        respond_to do |wants|
          wants.html { redirect_to args }
          wants.js do
            action = args[:action]
            self.send action
          end
        end
      end
      def render_toolbox_action action
        respond_to do |wants|
          wants.html do
            begin
              self.send("after_#{action}")
            rescue NoMethodError
              # TODO should we really hard code the layout here?
              render :template => action.to_s, :layout => 'admin'
            end
          end
          wants.js do
            render :update do |page|
              [ "before_update_toolbox_for_#{action}",
                "update_toolbox_for_#{action}", 
                "after_update_toolbox_for_#{action}"
              ].each do |meth|
                  begin
                    controller.send(meth,page)
                  rescue NoMethodError
                  end
                end
              controller.update_toolbox_status(page)
            end
          end
          wants.xml { render :text => (@model||@models).to_xml}
        end
      end
      def update_toolbox_for_index(page)
        if params[:search]
          target = page.toolbox.last.find("div.search_results.#{self.controller_name}")
          if @models.empty?
            target.html("No #{self.controller_name.humanize} found.")
          else
            target.html(page.context.list_of(@models, :force_list => true))
          end
        else
          page.push_or_refresh( 
            :partial => "/list", :object => @models,
            :title => self.controller_name.humanize
          )
        end
      end
      def update_toolbox_for_edit(page)
        page.push_toolbox_content(
          :partial => "/form", :object => @model,
          :title => "Edit #{@model.class_name} (#{@model.id})"
        )
      end
      def update_toolbox_for_new(page)
        page.push_toolbox_content(
          :partial => "/form", :object => @model,
          :title => "New #{@model.class_name}"
        )
      end
      def update_toolbox_for_show(page)
        page.push_or_refresh(
          :partial => "/show", :object => @model,
          :title => "#{@model.class_name} (#{@model.id})"
        )
      end

      def update_toolbox_for_created(page)
        if non_form_submit?
          params[@model].keys.each do |meth|
            page.toolbox_update_model_attribute model, meth
          end if params[@model]
        else
          page.update_last_toolbox_frame(   # replace the form with /show
            :partial => "/show", :object => @model,
            :title => "#{@model.class_name} (#{@model.id})"
          )
        end
      end

      def update_toolbox_for_updated(page)
        if non_form_submit?
          params[@model].keys.each do |meth|
            page.toolbox_update_model_attribute model, meth
          end if params[@model]
        else
          page.toolbox.pop_and_refresh_last()
        end
      end

      # TODO destroy from show (must load @models) / update previous list
      def update_toolbox_for_destroyed(page)
        page.toolbox.pop_and_refresh_last()
      end

      def update_toolbox_for_failed_create(page)
        if non_form_submit?
          page.push_toolbox_content(:partial => "/form", :object => @model)
        else
          page.update_last_toolbox_frame(:partial => "/form", :object => @model)
        end
      end
      def update_toolbox_for_failed_update(page)
        if non_form_submit?
          page.push_toolbox_content(:partial => "/form", :object => @model)
        else
          page.update_last_toolbox_frame(:partial => "/form", :object => @model)
        end
      end
      def update_toolbox_for_failed_destroy(page)
        page.update_last_toolbox_frame(:partial => "/show", :object => @model)
      end

      def update_toolbox_status(page)
        page.toolbox.set_status(
          if notice = page.context.flash[:notice]
            notice
          elsif error = page.context.flash[:error]
            error
          else
            "Done"
          end
        )
      end

      # standard actions (html format)
      def after_created
        logger.debug(" ##### after created called for #{@model.inspect}")
        redirect_to :action => 'show', :id => @model
      end

      def after_failed_create
        render :action => 'new'
      end

      def after_updated
        redirect_to @model
      end
      
      def after_failed_update
        render :action => 'edit'
      end

      def after_destroyed
        redirect_to :controller => @model.table_name, :action => 'index'
      end

      def after_failed_destroy
        render :action => 'show'
      end

      def rescue_error(exception)
        respond_to do |wants|
          wants.html { render :text => exception.inspect.to_s, :status => 500}
          wants.js do
            render :update do |page|
              page.toolbox_error exception
            end
          end
        end
      end

      def set_form_builder
        if request.xhr?
          ActionView::Base.default_form_builder = ToolboxFormBuilder
        else
          ActionView::Base.default_form_builder = NormalFormBuilder
        end
      end

      def non_form_submit?
        params[:commit].blank?
      end

    end
  end
end
