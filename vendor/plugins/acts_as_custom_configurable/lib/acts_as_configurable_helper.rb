module ActsAsConfigurable
  module FormBuilder
    def select_options
      returning "" do |html|
        html << %Q[<dl id="#{@object_name}_options">]
        @object.options.each do |item|
          html << option_item_field(item)
        end
        html << %q[</dl>]
      end
    end

    def define_options
      list_dom = "#{@object_name}_defined_options"
      returning "" do |html|
        html << %Q[<ul id="#{list_dom}" class="define_options">]
        html << @template.content_tag(:li, dummy_option_item_fields,:class => 'dummy')
        @object.options.each do |item|
          html << @template.content_tag(:li, define_option_item_fields(item) )
        end
        html << %q[</ul>]
      end
    end

    def dummy_option_item_fields
      returning '' do |html|
        html << @template.text_field_tag("#{@object_name}[define_options][name][]",'dummy', :class => 'name')
        html << @template.select_tag("#{@object_name}[define_options][type][]", option_type_option_group,  :class => 'type')
        html << @template.text_field_tag("#{@object_name}[define_options][default][]",'dummy', :class => 'default')
      end
    end

    # A pair of values gets shown in a di>dt+dd
    def dd(name,html)
      @template.di_dt_dd(name,html,:class => @template.cycle('odd','even', :name => 'options'))
    end

    def dummy_options_field(name)
      @template.text_field_tag("#{@object_name}[define_options][#{name}][]",'dummy')
    end

    def define_option_item_fields(item)
      returning "" do |html|
        html << option_name_text_field(item)
        html << option_type_selector_field(item)
        html << option_default_text_field(item)
      end
    end

    def option_default_text_field(item)
      @template.text_field_tag("#{@object_name}[define_options][default][]", item.default, :class => 'default')
    end

    def option_name_text_field(item)
      @template.text_field_tag("#{@object_name}[define_options][name][]", item.name, :class => "name")
    end

    def option_type_selector_field(item)
      @template.select_tag("#{@object_name}[define_options][type][]", option_type_option_group(item), :class => 'type')
    end

    def option_type_option_group(item=nil)
      @template.options_from_collection_for_select(%w(string integer boolean), :to_s, :to_s, item.andand.type_to_s)
    end

    def option_item_field(item)
      dd(
        @template.content_tag(:label, item.name),

        case item 
        when BooleanItem
          @template.hidden_field_tag("#{@object_name}[options][#{item.name}]", "0") + 
          @template.check_box_tag("#{@object_name}[options][#{item.name}]", "1", @object.options[item.name])
        else
          @template.text_field_tag("#{@object_name}[options][#{item.name}]", @object.options[item.name])
        end
      )
    end
  end
end
