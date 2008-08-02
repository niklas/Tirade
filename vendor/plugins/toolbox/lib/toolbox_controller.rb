module Tirade
  module Toolbox
    module Controller
      def self.included(base)
        base.extend(ClassMethods)
        #base.include(InstanceMethods)
      end
      module ClassMethods
        def feeds_toolbox_with model_name
          model_name = model_name.to_s
          model_plural = model_name.pluralize
          model_class_name = model_name.classify
          model_class = model_class_name.constantize
          class_eval do
            before_filter "fetch_#{model_name}", :only => [:show, :edit, :update, :destroy]
            helper 'interface'
            define_method "fetch_#{model_name}" do
              instance_variable_set "@#{model_name}", model_class.find(params[:id])
              instance_variable_set '@model', instance_variable_get("@#{model_name}")
            end
            define_method :render_toolbox_action do |action|
              render :template => "/model/#{action}"
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
              instance_variable_set "@#{model_name}", model_class.new
              render_toolbox_action :new
            end
            define_method :create do
              instance_variable_set "@#{model_name}", model_class.new(params[model_name])
              model = instance_variable_get "@#{model_name}"
              if model.save
                flash[:notice] = "#{model_class_name} #{model.id} created."
                redirect_to :action => 'show', :id => model
              else
                flash[:notice] = "Creating #{model_class_name} failed."
                render_toolbox_action :new
              end
            end
            define_method :update do
              model = instance_variable_get "@#{model_name}"
              if model.update_attributes(params[model_name])
                flash[:notice] = "#{model_class_name} #{model.id} updated."
                redirect_to :action => 'show', :id => model
              else
                flash[:notice] = "Updating #{model_class_name} #{model.id} failed."
                render_toolbox_action :edit
              end
            end
            define_method :destroy do
              model = instance_variable_get "@#{model_name}"
              if model.destroy
                flash[:notice] = "#{model_class_name} #{model.id} destroyed."
                redirect_to :action => 'index'
              else
                flash[:notice] = "Destroying #{model_class_name} #{model.id} failed."
                redirect_to :action => 'show', :id => model
              end
            end
          end
        end
      end
    end
  end
end
