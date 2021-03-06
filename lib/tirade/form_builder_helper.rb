module Tirade

  module TranslatingInstanceTag
    # FIXME if you can do that without alias_method_chain, please show me. 
    # I seem to be too stupid to overwrite a method by just including a Module
    def self.included(base)
      base.class_eval do
        # disabled, because we set the locale in the routes and do not have multi-language forms
        # (editing two languages at the same time . even this could be done with to separate forms)
        #alias_method_chain :tag_name, :translation
      end
    end
    def tag_name_with_translation
      if @object && @object.respond_to?(:acts_as?) && @object.acts_as?(:translated) && @object.translates?(@method_name)
        tag_name_without_translation.sub %r~\[~, "[translations][#{I18n.locale}]["
      else
        tag_name_without_translation
      end
    end
  end
  ActionView::Helpers::InstanceTag.class_eval do
    include TranslatingInstanceTag
  end

  module FormBuilderHelper
    include ScopeFormBuilderMethods

    def text_field(field, options = {})
      wrap(field, options, super(field,options))
    end

    def password_field(field, options = {})
      wrap(field, options, super(field,options))
    end

    def text_area(field, options = {})
      if @object.markup?(field)
        options[:class] ||= ''
        options[:class] += ' markitup textile'
      end
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
      wrap(field,options, super(field, options, html_options))
    end

    def tree_select(field, collection, value_method, text_method, options = {}, html_options = {})
      wrap(field, options, super)
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
      return "Wrong association type (#{reflection.macro}), needed has_many" unless [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
      things = @object.send(assoc)
      fkey = opts.delete(:foreign_key) || reflection.association_foreign_key.andand.pluralize || "#{reflection.name.to_s.singularize}_ids"
      inner = ''
      inner << @template.list_of(things, :force_list => true)
      inner << @template.live_search_for(assoc.to_s.singularize)
      inner << @template.hidden_field_tag("#{@object_name}[#{fkey}][]","empty", :class => 'association_id')

      @template.add_class_to_html_options opts, 'many'
      @template.add_class_to_html_options opts, 'associations'
      @template.add_class_to_html_options opts, 'association'
      wrap(assoc, opts, inner)
    end

    def has_one(assoc, opts={})
      unless @object.class.reflections.has_key?(assoc)
        return "does not know about #{assoc.to_s.humanize}"
      end
      reflection = @object.class.reflections[assoc]
      return "Wrong association type (#{reflection.macro}), needed belongs_to/has_one" unless [:has_one, :belongs_to].include?(reflection.macro)
      assocs = assoc.to_s.pluralize
      thing = @object.send(assoc)
      thing = thing.first if thing.is_a?(Array) # HACK for dynamic content of Rendering
      inner = ''
      inner << @template.list_of([thing], :force_list => true)
      inner << @template.live_search_for_reflection(reflection, opts) unless opts[:search] == false
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
      wrap(assoc, {:class => 'one association associations'}, inner)
    end

    def sort(assoc=:children, opts={})
      unless @object.class.reflections.has_key?(assoc)
        return "does not know about #{assoc.to_s.humanize}"
      end
      reflection = @object.class.reflections[assoc]
      return "Wrong association type (#{reflection.macro}), needed has_many" unless [:has_many, :has_and_belongs_to_many].include?(reflection.macro)
      things = @object.send(assoc)
      inner = returning '' do |html|
        html << @template.list_of(things, :force_list => true)
      end
      wrap(assoc, {:class => 'sort'}, inner)
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
      collection = @object.send field
      returning '' do |inner|
        values.each do |value|
          inner << @template.di_dt_dd(
            label(value.to_s),
            @template.check_box_tag(name, value.to_s, collection.include?(value.to_s))
          )
        end
        if none = opts.delete(:none)
          inner << @template.di_dt_dd(
            label('(None)'),
            @template.check_box_tag(name, none, collection.empty?)
          )
        end
      inner
      end
    end

    # FIXME do not show impossible movies
    def select_parent(field=:parent_id, opts={})
      klass = opts[:klass] || @object.class
      if klass.column_names.include?('url')
        choices = klass.all(:order => 'url').map do |i|
          ["#{'> ' * i.level} #{i.title}", i.id]
        end
      else
        choices = klass.all(:order => 'parent_id').map do |i|
          [i.title, i.id]
        end
      end
      opts[:include_blank] = true
      opts[:label] ||= "Parent #{@object_name}"
      select field, choices, opts
    end

    private

    def wrap(field, options, tag_output)
      @template.add_class_to_html_options options, field.to_s
      label = label_for(field, options.delete(:label))
      @template.content_tag(
        :div,
        label + ' ' + tag_output,
        options
      )
    end

    def label_for(field, given=nil)
      if given != false
        @template.content_tag(
          :label, (given || field.to_s.humanize), {:for => "#{@object_name.to_s}_#{field}"}
        )
      else
        ''
      end
    end

  end
end
