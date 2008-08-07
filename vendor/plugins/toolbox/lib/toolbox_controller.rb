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
              if model.save
                flash[:notice] = "#{model_class_name} #{model.id} created."
                redirect_toolbox_to :action => 'show', :id => model
              else
                flash[:notice] = "Creating #{model_class_name} failed."
                render_toolbox_action :new
              end
            end
            define_method :update do
              model = instance_variable_get "@model"
              if model.update_attributes(params[model_name])
                flash[:notice] = "#{model_class_name} #{model.id} updated."
                redirect_toolbox_to :action => 'show', :id => model
              else
                flash[:notice] = "Updating #{model_class_name} #{model.id} failed."
                render_toolbox_action :edit
              end
            end
            define_method :destroy do
              model = instance_variable_get "@#{model_name}"
              if model.destroy
                flash[:notice] = "#{model_class_name} #{model.id} destroyed."
                redirect_toolbox_to :action => 'index'
              else
                flash[:notice] = "Destroying #{model_class_name} #{model.id} failed."
                redirect_toolbox_to :action => 'show', :id => model
              end
            end
          end
        end
      end
    end
    module InstanceMethods
      def redirect_toolbox_to args
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
          wants.html { render :template => "/model/#{action}" }
          wants.js do
            render :update do |page|
              [ "before_update_toolbox_for_#{action}",
                "update_toolbox_for_#{action}", 
                "after_update_toolbox_for_#{action}"].each do |meth|
                  begin
                    ActiveRecord::Base.logger.debug("Toolbox: calling #{controller}##{meth}")
                    controller.send(meth,page)
                  rescue NoMethodError
                  end
                end
            end
          end
        end
      end
      def update_toolbox_for_index(page)
        page.update_toolbox(
          :header => self.controller_name.humanize,
          :content => {
            :partial => "/#{self.controller_name}/list", 
            :object => @models
          }
        )
      end
      def update_toolbox_for_edit(page)
        page.update_toolbox(
          :header => "Edit #{@model.class_name} (#{@model.id})",
          :content => {:partial => "/#{@model.table_name}/form", :object => @model}
        )
      end
      def update_toolbox_for_new(page)
        page.update_toolbox(
          :header => "New #{@model.class_name}",
          :content => {:partial => "/#{@model.table_name}/form", :object => @model}
        )
      end
      def update_toolbox_for_show(page)
        page.update_toolbox(
          :header => "#{@model.class_name} (#{@model.id})",
          :content => {:partial => "/#{@model.table_name}/show", :object => @model}
        )
      end

    end
  end
end
