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

    def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
      options[:class] ||= ''
      options[:class] += ' checkbox'
      wrap(field, options,super(field, options, checked_value, unchecked_value))
    end

    def define_options
      wrap('Define Options', {}, super)
    end

    def select_options
      wrap('Options', {}, super)
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
      inner << @template.text_field_tag("#{assoc}_search_term", nil, :href => @template.url_for(:controller => assoc), :class => 'search_term')
      inner << @template.content_tag(:div, "Search for #{assoc.to_s.humanize}", :class => 'search_results many')
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
      inner << @template.content_tag(
        :ul,
        @template.list_item(thing),
        :class => 'association one list'
      )
      inner << @template.text_field_tag("#{assoc}_search_term", nil, :href => @template.url_for(:controller => assocs), :class => 'search_term')
      inner << @template.content_tag(:div, "Search for #{assocs.humanize}", :class => 'search_results one')
      inner << @template.hidden_field_tag("#{@object_name}[#{assoc}_id]", thing.id, :class => 'association_id')
      if reflection.options[:polymorphic]
        inner << @template.hidden_field_tag("#{@object_name}[#{reflection.options[:foreign_type]}]", thing.class_name, :class => 'association_type')
      end
      wrap(assoc, {}, inner)
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
