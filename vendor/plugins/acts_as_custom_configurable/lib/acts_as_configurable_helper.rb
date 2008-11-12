module ActsAsConfigurable
  module FormBuilder
    def select_options
      returning "" do |html|
        html << %Q[<ul id="#{@object_name}_options">]
        @object.options.each do |item|
          html << @template.content_tag(:li, option_item_field(item), :class => @template.cycle('odd','even', :name => 'options') )
        end
        html << %q[</ul>]
      end
    end

    def define_options
      list_dom = "#{@object_name}_defined_options"
      returning "" do |html|
        html << dummy_option_item_fields
        html << %Q[<ul id="#{list_dom}" class="define_options">]
        @object.options.each do |item|
          html << @template.content_tag(:li, define_option_item_fields(item) )
        end
        html << %q[</ul>]
      end
    end

    def dummy_option_item_fields
      returning '' do |html|
        html << @template.hidden_field_tag("#{@object_name}[define_options][name][]",'dummy')
        html << @template.hidden_field_tag("#{@object_name}[define_options][type][]",'string')
        html << @template.hidden_field_tag("#{@object_name}[define_options][default][]",'dummy')
      end
    end

    def define_option_item_fields(item)
      returning "" do |html|
        html << @template.text_field_tag("#{@object_name}[define_options][name][]", item.name, :class => "name")
        html << option_type_selector(item)
        html << @template.text_field_tag("#{@object_name}[define_options][default][]", item.default, :class => 'default')
      end
    end

    def option_type_selector(item)
      @template.select_tag("#{@object_name}[define_options][type][]", option_type_option_group(item), :class => 'type')
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
