dependencies = ActiveSupport.const_defined?(:Dependencies) ? ActiveSupport::Dependencies : Dependencies
dependencies.module_eval do
  def load_missing_constant_with_tirade(from_mod, const_name)
    qualified_name = qualified_name_for from_mod, const_name
    begin
      load_missing_constant_without_tirade(from_mod, const_name)
    rescue NameError => e
      if qualified_name =~ /^(\w+s)Controller$/i
        class_name = $1.singularize
        if Tirade::ActiveRecord::Content.class_names.include?(class_name)
          ActiveRecord::Base::logger.debug("Tirade will define a #{qualified_name}")
          Object.class_eval <<-EODECL
            class #{qualified_name} < ManageResourceController::Base
              unloadable
            end
          EODECL
          autoloaded_constants << qualified_name
          from_mod.const_get(qualified_name)
        else
          raise e
        end
      else
        raise e
      end
    end
  end

  alias_method_chain :load_missing_constant, :tirade
end
