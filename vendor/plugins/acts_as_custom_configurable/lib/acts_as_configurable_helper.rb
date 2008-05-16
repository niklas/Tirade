module ActsAsConfigurable
  module FormBuilder
    def select_options
      returning "" do |html|
        html << %Q[<ul id="#{@object_name}_options">]
        @object.options.each_item do |item_name, item|
          html << @template.content_tag(:li, option_item_field(item) )
        end
        html << %q[</ul>]
      end
    end

    def define_options
      returning "" do |html|
        html << %Q[<ul id="#{@object_name}_defined_options">]
        @object.options.each_item do |item_name, item|
          html << @template.content_tag(:li, define_option_item_fields(item) )
        end
        html << %q[</ul>]
      end
    end

    def define_option_item_fields(item)
      returning "" do |html|
        html << @template.text_field_tag("#{@object_name}[defined_options][name][]", item.name)
        html << option_type_selector(item)
        html << @template.text_field_tag("#{@object_name}[defined_options][default][]", item.default)
      end
    end

    def option_type_selector(item)
      @template.select_tag("#{@object_name}[defined_options][type][]", option_type_option_group(item))
    end

    def option_type_option_group(item)
      @template.options_from_collection_for_select(%w(string integer boolean), :to_s, :to_s, item.type_to_s)
    end

    def option_item_field(item)
      returning "" do |html|
        field_dom = "#{@object_name}_options_#{item.name}"
        html << @template.content_tag(:label, item.name, :for => field_dom)
        html << case item 
                when BooleanItem
                  @template.check_box_tag("#{@object_name}[options][#{item.name}]", "1", @object.options[item.name], :id => field_dom)
                else
                  @template.text_field_tag("#{@object_name}[options][#{item.name}]", @object.options[item.name], :id => field_dom)
                end
      end
    end
  end
end
