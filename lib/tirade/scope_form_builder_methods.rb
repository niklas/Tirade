module Tirade
  module ScopeFormBuilderMethods
    def select_order_scope(content_type)
      fields = content_type.column_names
      collection_select :order, fields.map {|f| "ascending_by_#{f}" } + fields.map {|f| "descending_by_#{f}" }, :to_s, :to_s
    end

    def scope_all_columns(content_type)
      inner = returning '' do |html|
        html << @template.select_tag("#{@object_name}[field][]", content_type.column_names)
        content_type.columns.each do |column|
          html << @template.select_tag("#{@object_name}[comparison][]", comparisons_for_column(column))
          html << field_for_scope_column(column)
        end
      end
      wrap('scope', {:label => 'Scope'}, inner)
    end

    private
    def field_for_scope_column(column)
      case column.type
      when :integer, :string, :text
        @template.text_field_tag "#{@object_name}[value][]"
      when :datetime
        datetime_select_without_wrap "#{@object_name}[value][]"
      else
        @template.warning("Column type #{column.type} not supported (#{@object_name}##{column.name})")
      end
    end

    def comparisons_for_column(column)
      case column.type
      when :integer, :datetime
        %w( greater_than greater_than_or_equal_to equals less_than_or_equal_to less_than )
      when :string, :text
        %( equals does_not_equal begins_with ends_with like )
        []
      end
    end

  end
end
