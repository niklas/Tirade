module Tirade

  module ScopeFormBuilderMethods
    def define_scope
      inner = returning '' do |html|
        scopings = @object.scopings
        html << scope_blueprint
        scopings.each do |scoping|
          html << single_scoping(scoping)
        end
        html << scope_select_order
        html << scope_hide_expired_content
      end
      wrap('scope', {:label => 'Scope', :class => 'define_scope'}, inner)
    end


    def scope_blueprint
      single_scoping(Rendering::Scoping.new('attribute','comparison','value'), :class => 'blueprint', :style => 'display: none')
    end

    def scope_select_order
      ordering = @object.ordering
      inner = returning '' do |html|
        fields_for "scope_definition", ordering, :builder => self.class do |scope_fields|
          html << label('Order')
          html << scope_fields.select_without_wrap(:attribute, @object.content_class.column_names , {}, :name => 'order_attribute', :class => 'order_attribute', :declare => true)
          html << scope_fields.select_without_wrap(:direction, ['ascend', 'descend'], {}, :name => 'order_direction', :class=> 'order_direction', :declare => true)
          html << scope_fields.hidden_field(:order, :class => 'order_value')
        end
      end
      @template.content_tag(:div, inner, :class => 'order')
    end

    private

    def scope_hide_expired_content
      inner = check_box(:hide_expired_content)
      @template.content_tag(:div, inner, :class => 'hide_expired_content')
    end

    def single_scoping(scoping, opts={})
      @template.add_class_to_html_options opts, 'scoping'
      returning '' do |html|
        fields_for "scope_definition", scoping, :builder => self.class do |scope_fields|
          html << @template.render(:partial => '/shared/scope_fields', :object => scope_fields, :locals => {:rendering => @object, :scoping => scoping, :options => opts})
        end
      end
    end


    def select_order_scope(content_type)
      fields = content_type.column_names
      collection_select :order, fields.map {|f| "ascending_by_#{f}" } + fields.map {|f| "descending_by_#{f}" }, :to_s, :to_s
    end

    def scope_all_columns(content_type)
      inner = returning '' do |html|
        html << @template.select_tag("#{@object_name}[field]", content_type.column_names)
        content_type.columns.each do |column|
          html << @template.select_tag("#{@object_name}[comparison][]", comparisons_for_column(column))
          html << field_for_scope_column(column)
        end
      end
      wrap('scope', {:label => 'Scope'}, inner)
    end

    def select_scope_from_pool(content_type)
      inner = returning '' do |html|
        html << @template.link_to('add', '#', :class => 'add')
        html << @template.link_to('OK', '#', :class => 'create_scope ok')
        html << @template.select_tag('select_comparison', [])
        html << @template.select_tag('select_column', [])
      end
      meta = {:columns => content_type.columns, :comparisons => content_type.comparisons_grouped_by_column}
      wrap('define', {:label => "Define Scope for #{content_type}", :data => meta.to_json}, inner)
    end

    # All possible scopes for given content type
    def scope_pool(content_type)
      inner = returning '' do |html|
        content_type.columns.each do |column|
          comparisons_for_column(column).each do |comparison|
            html << field_for_scope_column_comparison(column, comparison)
          end
        end
      end
      @template.content_tag :div, inner, :class => 'pool', :style => 'display: none'
    end

    private
    def field_for_scope_column_comparison(column, comparison)
      name = "#{column.name}_#{comparison}"
      case column.type
      when :integer, :string, :text
        text_field name
      when :datetime
        datetime_select name
      else
        @template.warning("Column type #{column.type} not supported (#{@object_name}##{name})")
      end
    end

    def comparisons_for_column(column)
      case column.type
      when :integer, :datetime
        %w( greater_than greater_than_or_equal_to equals less_than_or_equal_to less_than )
      when :string, :text
        %w( equals does_not_equal begins_with ends_with like )
      else
        []
      end
    end

  end
end
