module Tirade
  module Toolbox
    module Controller
      def self.included(base)
        base.extend(ClassMethods)
        base.helper :interface
        base.helper :toolbox
        base.class_eval { include(InstanceMethods) }
      end
      module ClassMethods
        def feeds_toolbox_with model_name
          model_name = model_name.to_s
          model_plural = model_name.pluralize
          model_class_name = model_name.classify
          model_class = model_class_name.constantize
          class_eval do
            before_filter "fetch_#{model_name}", :only => [:show, :edit, :update, :destroy]
            define_method "fetch_#{model_name}" do
              instance_variable_set "@#{model_name}", model_class.find(params[:id])
              instance_variable_set '@model', instance_variable_get("@#{model_name}")
              instance_variable_set '@model_name', model_name
            end
            define_method :index do
              instance_variable_set "@#{model_plural}", model_class.find(:all) 
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
              instance_variable_set '@model', model_class.new(params[model_name])
              model = instance_variable_get "@model"
              instance_variable_set "@#{model_name}", model
              if model.save
                flash[:notice] = "#{model_class_name} #{model.id} created."
                render_toolbox_action :created
              else
                flash[:notice] = "Creating #{model_class_name} failed."
                render_toolbox_action :fail_created
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
          # TODO should we really hard code the layout here?
          wants.html { render :template => action.to_s, :layout => 'admin' }
          wants.js do
            render :update do |page|
              [ "before_update_toolbox_for_#{action}",
                "update_toolbox_for_#{action}", 
                "after_update_toolbox_for_#{action}"].each do |meth|
                  begin
                    controller.send(meth,page)
                  rescue NoMethodError
                  end
                end
              controller.update_toolbox_status(page)
            end
          end
        end
      end
      def update_toolbox_for_index(page)
        page.push_toolbox_content( 
          :partial => "/#{self.controller_name}/list", :object => @models,
          :title => self.controller_name.humanize
        )
        page.toolbox.slide_left
      end
      def update_toolbox_for_edit(page)
        page.push_toolbox_content(
          :partial => "/#{@model.table_name}/form", :object => @model,
          :title => "Edit #{@model.class_name} (#{@model.id})"
        )
        page.toolbox.slide_left
      end
      def update_toolbox_for_new(page)
        page.push_toolbox_content(
          :partial => "/#{@model.table_name}/form", :object => @model,
          :title => "New #{@model.class_name}"
        )
        page.toolbox.slide_left
      end
      def update_toolbox_for_show(page)
        page.push_toolbox_content(
          :partial => "/#{@model.table_name}/show", :object => @model,
          :title => "#{@model.class_name} (#{@model.id})"
        )
        page.toolbox.slide_left
      end

      def update_toolbox_for_created(page)
        page.push_toolbox_content(
          :partial => "/#{@model.table_name}/show", :object => @model,
          :title => "#{@model.class_name} (#{@model.id})"
        )
        page.toolbox.remove_second_last
      end

      def update_toolbox_for_updated(page)
        page.push_toolbox_content(
          :partial => "/#{@model.table_name}/show", :object => @model,
          :title => "#{@model.class_name} (#{@model.id})"
        )
        page.toolbox.remove_second_last
      end

      # TODO destroy from show (must load @models)
      def update_toolbox_for_destroyed(page)
        page.push_toolbox_content( 
          :partial => "/#{self.controller_name}/list", :object => @models,
          :title => self.controller_name.humanize
        )
        page.toolbox.slide_left
      end

      def update_toolbox_for_failed_create(page)
        page.update_last_toolbox_frame(:partial => "/#{@model.table_name}/form", :object => @model)
      end
      def update_toolbox_for_failed_update(page)
        page.update_last_toolbox_frame(:partial => "/#{@model.table_name}/form", :object => @model)
      end
      def update_toolbox_for_failed_destroy(page)
        page.update_last_toolbox_frame(:partial => "/#{@model.table_name}/show", :object => @model)
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

    end
  end
end
