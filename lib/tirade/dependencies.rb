dependencies = ActiveSupport.const_defined?(:Dependencies) ? ActiveSupport::Dependencies : Dependencies
dependencies.module_eval do
  def load_missing_constant_with_tirade(from_mod, const_name)
    from_mod = guard_against_anonymous_module(from_mod)
    qualified_name = qualified_name_for from_mod, const_name
    begin
      load_missing_constant_without_tirade(from_mod, const_name)
    rescue NameError => e
      if qualified_name =~ /^(\w+)Controller$/i
        class_name = $1.singularize
        if  Tirade::ActiveRecord::Content.class_names.include?(class_name)
          ActiveRecord::Base::logger.debug("Tirade will define a #{qualified_name}")
          Object.class_eval <<-EODECL
            class #{qualified_name} < ManageResourceController::Base
            end
          EODECL
          autoloaded_constants << qualified_name
          return qualified_name.constantize
        end
      else
        raise
      end
    end
  end

  alias_method_chain :load_missing_constant, :tirade
end
