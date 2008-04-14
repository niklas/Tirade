module ActiveRecord
  class Base
    class << self

      # FIXME Quick-fix http://dev.rubyonrails.org/ticket/10686 until it is released
      def update_all(updates, conditions = nil, options = {})
        sql  = "UPDATE #{table_name} SET #{sanitize_sql_for_assignment(updates)} "
        scope = scope(:find)
        add_conditions!(sql, conditions, scope)
        add_order!(sql, options[:order], nil)
        add_limit!(sql, options, nil)
        connection.update(sql, "#{name} Update")
      end
    end
  end
end
