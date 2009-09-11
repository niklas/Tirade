require 'rails_generator/generators/components/model/model_generator'

class ContentTypeGenerator < ModelGenerator

  def manifest

    record do |m|

      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      root = File.join('vendor','plugins',"tirade_#{table_name}")
      m.directory root

      m.file 'init.rb', File.join(root,'init.rb')

      # Model
      m.directory File.join(root, 'app/models')
      m.template 'model.rb',      File.join(root, 'app/models', "#{file_name}.rb")

      # Specs
      m.directory File.join(root, 'spec/models')
      m.template 'model_spec.rb',       File.join(root, 'spec/models', "#{file_name}_spec.rb")
      unless options[:skip_fixture]
        m.directory File.join(root, 'spec/fixtures')
        m.template 'model:fixtures.yml',  File.join(root, 'spec/fixtures', "#{table_name}.yml")
      end

      # Model
      m.directory File.join(root, 'app/controllers')
      m.template 'controller.rb',      File.join(root, 'app/controllers', "#{table_name}_controller.rb")

      # Tirade default views
      m.directory File.join(root, 'app/views', table_name)
      m.template 'views/_show.html.erb', File.join(root, 'app/views', table_name, "_show.html.erb")
      m.template 'views/_form.html.erb', File.join(root, 'app/views', table_name, "_form.html.erb")
      m.template 'views/_list_item.html.erb', File.join(root, 'app/views', table_name, "_list_item.html.erb")

      unless options[:skip_migration]
        m.directory File.join(root, 'db/migrate', table_name)
        m.template 'model:migration.rb', File.join(root, 'db/migrate', "001_create_#{table_name}.rb"),
          :assigns => { :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}" }
      end

      m.directory File.join(root,'config')
      m.template 'config/routes.rb', File.join(root, 'config/routes.rb')


      m.directory File.join(root,'public', 'images', 'icons', 'types')

      m.readme 'INSTALLED'

    end
  end

end
