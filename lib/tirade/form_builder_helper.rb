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
      unless @object.class.reflections.has_key?(:picturizations)
        return 'does not know about pictures'
      end
      inner = ''
      inner << "Search + click to add/remove pictures for '#{@object.title}'"

      list_dom = "pictures_list"
      inner << @template.content_tag(:div,@template.render(:partial => '/images/for_select', :collection => @object.images), {:id => list_dom, :class => 'pictures_list'})

      inner << @template.text_field_tag('search_images')
      results_dom = "search_results"
      inner << @template.content_tag(:div,'results', {:id => results_dom, :class => 'pictures_list'})
      inner << @template.hidden_field_tag("#{@object_name}[image_ids][]","empty")
      wrap('select picture', {}, inner)
    end

    def has_many(assoc, opts={})
      unless @object.class.reflections.has_key?(assoc)
        return "does not know about #{assoc.to_s.humanize}"
      end
      reflection = @object.class.reflections[assoc]
      things = @object.send(assoc)
      fkey = opts.delete(:foreign_key) || "#{assoc.to_s.singularize}_ids"
      inner = ''
      inner << @template.list_of(things, :force_list => true)
      inner << @template.text_field_tag('search_term', nil, :href => @template.url_for(:controller => assoc))
      inner << @template.content_tag(:div, "Search for #{assoc.to_s.humanize}", :class => 'search_results')
      inner << @template.hidden_field_tag("#{@object_name}[#{fkey}][]","empty")
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
