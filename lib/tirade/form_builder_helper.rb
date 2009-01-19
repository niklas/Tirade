module Tirade
  module FormBuilderHelper
    def text_field(field, options = {})
      wrap(field, options, super(field,options))
    end

    def text_area(field, options = {})
      wrap(field, options, super(field,options.reverse_merge(:rows => 2)))
    end

    def collection_select(field, collection, value_method, text_method, options = {}, html_options = {})
      wrap(field, options, super(field, collection, value_method, text_method, options, html_options))
    end

    def select(field, choices, options = {}, html_options = {})
      wrap(field,options, super(field, choices, options, html_options))
    end

    def datetime_select(field, options = {}, html_options = {})
      @template.content_tag(
        :span,
        wrap(field,options, super(field, options, html_options)),
        :class => 'datetime'
      )
    end

    def date_select(field, options = {}, html_options = {})
      @template.content_tag(
        :span,
        wrap(field,options, super(field, options, html_options)),
        :class => 'date'
      )
    end

    def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
      options[:class] ||= ''
      options[:class] += ' checkbox'
      wrap(field, options,super(field, options, checked_value, unchecked_value))
    end

    def select_picture
      has_many :images, :foreign_key => 'image_ids'
    end

    def has_many(assoc, opts={})
      unless @object.class.reflections.has_key?(assoc)
        return "does not know about #{assoc.to_s.humanize}"
      end
      reflection = @object.class.reflections[assoc]
      return "Wrong association type (#{reflection.macro}), needed has_many" unless reflection.macro == :has_many
      things = @object.send(assoc)
      fkey = opts.delete(:foreign_key) || "#{assoc.to_s.singularize}_ids"
      inner = ''
      inner << @template.list_of(things, :force_list => true)
      href   = @template.url_for(:controller => assoc)
      inner << @template.text_field_tag("#{assoc}_search_term", nil, :href => href, :class => 'search_term')
      inner << @template.content_tag(:div, "Search for #{assoc.to_s.humanize}", :class => "search_results many #{assoc}")
      inner << @template.hidden_field_tag("#{@object_name}[#{fkey}][]","empty")
      wrap(assoc, {}, inner)
    end

    def has_one(assoc, opts={})
      unless @object.class.reflections.has_key?(assoc)
        return "does not know about #{assoc.to_s.humanize}"
      end
      reflection = @object.class.reflections[assoc]
      return "Wrong association type (#{reflection.macro}), needed belongs_to/has_one" unless [:has_one, :belongs_to].include?(reflection.macro)
      assocs = assoc.to_s.pluralize
      thing = @object.send(assoc)
      inner = ''
      inner << @template.list_of([thing])
      inner << @template.live_search_for(opts.delete(:types) || assoc)
      if thing
        inner << @template.hidden_field_tag("#{@object_name}[#{assoc}_id]", thing.id, :class => 'association_id')
        if reflection.options[:polymorphic]
          inner << @template.hidden_field_tag("#{@object_name}[#{reflection.options[:foreign_type]}]", thing.class_name, :class => 'association_type')
        end
      else
        inner << @template.hidden_field_tag("#{@object_name}[#{assoc}_id]", nil, :class => 'association_id')
        if reflection.options[:polymorphic]
          inner << @template.hidden_field_tag("#{@object_name}[#{reflection.options[:foreign_type]}]", nil, :class => 'association_type')
        end
      end
      wrap(assoc, {:class => 'one association'}, inner)
    end

    def actings
      returning '' do |html|
        @object.acting_roles.each do |role|
          view_path = @object.class.acting_fields_view_path(role)
          if File.exists?(view_path)
            html << @template.render(:file => view_path, :locals => {:fields => self})
          end
        end
      end
    end

    def multiple_checkbox(field,values,opts={})
      name = "#{@object_name}[#{field}][]"
      inner = ''
      collection = @object.send field
      values.each do |value|
        inner << @template.di_dt_dd(
          label(value.to_s),
          @template.check_box_tag(name, value.to_s, collection.include?(value.to_s))
        )
      end
      inner
    end

    private
    def wrap(field, options, tag_output)
      label = @template.content_tag(
        :label,
        (options.delete(:label) || field.to_s.humanize),
        {:for => "#{@object_name.to_s}_#{field}"}
      )
      @template.content_tag(
        :div,
        label + ' ' + tag_output,
        {:class => field.to_s}
      )
    end

  end
end
