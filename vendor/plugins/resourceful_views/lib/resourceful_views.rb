class ResourcefulViews
  
  def initialize
    @module ||= Module.new
    yield self
  end
  
  # generate a string of space-separated standardized CSS classnames
  def self.resourceful_classnames(primary_classname, *secondary_classnames)
    classnames = []
    classnames << primary_classname
    secondary_classnames.each do |classname|
      classnames << classname
      classnames << [classname, primary_classname].join('_') # a little help for IE
    end
    classnames.join(' ')
  end
  
  # Build resourceful helpers for a resource and install them into ActionView::Base
  def build_and_install_helpers_for_resource(resource)
    build_index_helper(resource)
    build_search_helper(resource)
    build_show_helper(resource)
    build_new_helper(resource)
    build_edit_helper(resource)
    build_destroy_helper(resource)
    build_list_helpers(resource)
    build_create_helper(resource)
    build_update_helper(resource)
    install_helpers
  end
  
  # Build resourceful helpers for a resource and install them into ActionView::Base
  def build_and_install_helpers_for_singular_resource(resource)
    build_show_helper(resource)
    build_new_helper(resource)
    build_edit_helper(resource)
    build_destroy_helper(resource)
    build_create_helper(resource)
    build_update_helper(resource)
    install_helpers
  end
  
  
  protected
  
  # Build the 'index_[resource]' helper
  # 
  # === Examples
  # 
  #   <% index_tables %>
  #
  #   renders:
  # 
  #   <a href="/tables" class="index tables index_tables">Index</a>
  #
  #   <% index_tables(:label => 'List') %>
  #
  #   renders:
  #
  #   <a href="/tables" class="index tables index_tables">List</a>
  # 
  def build_index_helper(resource)
    @module.module_eval <<-end_eval
      def index_#{resource.name_prefix}#{resource.plural}(*args)
        opts = args.extract_options!
        link_to_opts = {}
        label = opts.delete(:label) || 'Index'
        custom_classes = opts.delete(:class) || ''
        link_to_opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.plural}', 'index', *custom_classes.split)
        link_to_opts[:title] = opts.delete(:title) if opts[:title]
        args << opts unless opts.empty? #excess options are passed on to named route helper
        link_to(label, #{resource.name_prefix}#{resource.plural}_path(*args), link_to_opts)
      end
    end_eval
  end
  
  
  
  # Build the 'search_[resource]' helper
  # 
  # === Examples
  # 
  #   <% search_tables %>
  #
  #   renders:
  # 
  #   <form action="/tables" method="get" class="index tables index_tables search search_tables">
	#	    <input type="text" name="query" />
	# 	  <button type="submit">Search</button>
	#   </form>
  #
  #   <% search_tables(:label => 'Find') %>
  # 
  #   renders:
  # 
  #   <form action="/tables" method="get" class="index tables index_tables search search_tables">
	#	    <input type="text" name="query" />
	# 	  <button type="submit">Find</button>
	#   </form>
  #   
  def build_search_helper(resource)
    @module.module_eval <<-end_eval
      def search_#{resource.name_prefix}#{resource.plural}(*args)
        opts = args.extract_options!
        opts_for_button = {:type => 'submit'}
        opts_for_button[:title] = opts.delete(:title) if opts[:title]
        label = opts.delete(:label) || 'Search'
        custom_classes = opts.delete(:class) || ''
        content_tag('form', :action => #{resource.name_prefix}#{resource.plural}_path(*args), :method => :get, :class => ResourcefulViews.resourceful_classnames('#{resource.plural}', 'search', *custom_classes.split)) do
          token_tag.to_s +
          text_field_tag(:query, @query, :id => nil) +
          content_tag(:button, label, opts_for_button)
        end
      end
    end_eval
  end
  
  # Build the 'show_[resource]' helper
  # 
  # === Examples
  # 
  #   <% show_table_top(@table, @top) %>
  #
  #   renders:
  # 
  #   <a href="/tables/1/top" class="show top show_top">Show</a>
  #
  #   <% show_table_top(@table, @top, :label => @top.material) %>
  # 
  #   renders:
  # 
  #   <a href="/tables/1/top" class="show top show_top">Linoleum</a>
  #
  def build_show_helper(resource)
    @module.module_eval <<-end_eval
      def show_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        opts_for_link = {}
        opts_for_link[:title] = opts.delete(:title) if opts[:title]
        label = opts.delete(:label) || 'Show'
        custom_class = opts.delete(:class) || ''
        opts_for_link[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'show', *custom_class.split)
        args << opts unless opts.empty?
        link_to(label, #{resource.name_prefix}#{resource.singular}_path(*args), opts_for_link)
      end
    end_eval
  end


  
  # Build the 'new_[resource]' helper
  # 
  # === Examples
  # 
  #   <% new_table %>
  #
  #   renders:
  # 
  #   <a href="/tables/new" class="new table new_table">New</a>
  #
  #   <% new_table(:label => 'Add a table') %>
  # 
  #   renders:
  # 
  #   <a href="/tables/new" class="new table new_table">Add a table</a>
  #
  def build_new_helper(resource)
    @module.module_eval <<-end_eval
      def new_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        opts_for_link = {}
        opts_for_link[:title] = opts.delete(:title) if opts[:title]
        label = opts.delete(:label) || 'New'
        custom_class = opts.delete(:class) || ''
        opts_for_link[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'new', *custom_class.split)
        args << opts unless opts.empty?
        link_to(label, new_#{resource.name_prefix}#{resource.singular}_path(*args), opts_for_link)
      end
    end_eval
  end


  
  # Build the 'edit_[resource]' helper
  # 
  # === Examples
  # 
  #   <% edit_table_top(@table) %>
  #
  #   renders:
  # 
  #   <a href="/tables/1/top/edit" class="edit top edit_top">Edit</a>
  #
  #   <% edit_table_top(@table, :label => 'Change top') %>
  # 
  #   renders:
  # 
  #   <a href="/tables/1/top/edit" class="edit top edit_top">Change top</a>
  #
  def build_edit_helper(resource)
    @module.module_eval <<-end_eval
      def edit_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        opts_for_link = {}
        label = opts.delete(:label) || 'Edit'
        custom_class = opts.delete(:class) || ''
        opts_for_link[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'edit', *custom_class.split)
        opts_for_link[:title] = opts.delete(:title) if opts[:title]
        args << opts unless opts.empty?
        link_to(label, edit_#{resource.name_prefix}#{resource.singular}_path(*args), opts_for_link)
      end
    end_eval
  end


  
  # Build the 'destroy_[resource]' helper
  # 
  # === Examples
  # 
  #   <% destroy_table_leg(@table, @leg) %>
  #
  #   renders:
  # 
  #   <form action="/tables/1/legs/1" class="leg destroy destroy_leg" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit">Delete</button>
  #   </form>
  #
  #   <% destroy_table_leg(@table, @leg, :label => 'Remove leg') %>
  # 
  #   renders:
  # 
  #   <form action="/tables/1/legs/1" class="leg destroy destroy_leg" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit">Remove leg</button>
  #   </form>
  #
  def build_destroy_helper(resource)
    @module.module_eval <<-end_eval
      def destroy_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        opts_for_button = {:type => 'submit'}
        label = opts.delete(:label) || 'Delete'
        opts_for_button[:title] = opts.delete(:title) if opts[:title]
        custom_class = opts.delete(:class) || ''
        content_tag('form', :action => #{resource.name_prefix}#{resource.singular}_path(*args), :method => :post, :class => ResourcefulViews.resourceful_classnames('#{resource.singular}', 'destroy', *custom_class.split)) do
          hidden_field_tag(:_method, :delete, :id => nil) +
          token_tag.to_s +
          content_tag(:button, label, opts_for_button)
        end
      end
    end_eval
  end
  


  # Builds the list helpers
  #
  # === Examples
  #
  #   <% table_list do %>...<%- end -%>
  # 
  #   renders:
  # 
  #   <ul class="table_list">...</ul>
  # 
  #   <% the_table_list do %>..<% end %>
  # 
  #   renders:
  # 
  #   <ul id="table_list">...</ul>
  # 
  def build_list_helpers(resource)
    @module.module_eval <<-end_eval
      def #{resource.singular}_list(opts={}, &block)
        content = capture(&block)
        concat(content_tag(:ul, content, :class => ResourcefulViews.resourceful_classnames('#{resource.singular}_list', *(opts.delete(:class) || '').split)), block.binding)
      end
      def the_#{resource.singular}_list(opts={}, &block)
        content = capture(&block)
        concat(content_tag(:ul, content, :id => '#{resource.singular}_list'), block.binding)
      end
      def ordered_#{resource.singular}_list(opts={}, &block)
        content = capture(&block)
        concat(content_tag(:ol, content, :class => ResourcefulViews.resourceful_classnames('#{resource.singular}_list', *(opts.delete(:class) || '').split)), block.binding)
      end
      def the_ordered_#{resource.singular}_list(opts={}, &block)
        content = capture(&block)
        concat(content_tag(:ol, content, :id => '#{resource.singular}_list'), block.binding)
      end
    end_eval
  end
  


  # Build the 'create_[resource]' helper
  #
  # == Examples without block
  #
  #   <% create_table_top(:material => 'Mahogany') %>
  #
  #   renders:
  #
  #   <form action="/tables" class="table create create_table" method="post">
  #     <input type="hidden" type="table[material]" value="Mahogany" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  # If only the last argument is a hash (as above), it is interpreted as the attribute hash for the model.
  # If the last two arguments are hashes, the first is interpreted as the attribute hash, the second as the options hash:
  #
  #   <% create_table_leg(@table, {:material => 'Aluminum'}, :label => 'Add aluminum leg') %>
  #   
  #   renders:
  # 
  #   <form action="/tables/1/legs" class="leg create create_leg" method="post">
  #     <input type="hidden" type="table[magerial]" value="Aluminum" />
  #     <button type="submit">Add aluminum leg</button>
  #   </form>
  #
  # This means that if you want to pass only an options hash, you need to use an empty (attributes-)hash as the first argument:
  #
  #   <% create_table({}, :label => 'Add table') %>
  #   
  #   renders:
  #
  #   <form action="/tables" class="table create create_table" method="post">
  #     <button type="submit">Add table</button>
  #   </form>   
  #
  # == Examples with block
  #
  #   <% create_table do |form| %>
  #     <%= form.text_field :title %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #   
  #   renders:
  #
  #   <form action="/tables" class="table create create_table" method="post">
  #     <input type="text" type="table[title]" value="My title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  def build_create_helper(resource)
    @module.module_eval <<-end_eval
      def create_#{resource.name_prefix}#{resource.singular}(*args, &block)
        if block_given?
          opts = args.extract_options!
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'create', *(opts.delete(:class) || '').split)
          concat(form_tag(#{resource.name_prefix}#{resource.plural}_path(*args), {:class => css_classnames}), block.binding)
            fields_for('#{resource.singular}', &block)
          concat('</form>', block.binding)
        else
          opts = args.extract_options!
          if args.last.is_a?(Hash)
            resource_attributes = args.pop
          else #if only one hash is provided, it is assumed to be the resource attributes hash
            resource_attributes = opts
            opts = {}
          end
          label = opts.delete(:label) || 'Add'
          opts_for_button = {:type => 'submit'}
          opts_for_button[:title] = opts.delete(:title) if opts[:title]
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'create', *(opts.delete(:class) || '').split)
          content_tag('form', :method => :post, :action => #{resource.name_prefix}#{resource.plural}_path(*args), :class => css_classnames) do
            token_tag.to_s +
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join <<
            content_tag(:button, label, opts_for_button)
          end
        end
      end  
    end_eval
  end
  


  # Build the 'update_[resource](resource)' helper
  #
  # == Examples
  #
  #   <% update_table(@table, :title => 'My new title') %>
  #
  #   renders:
  #
  #   <form action="/tables/1" class="table update update_table" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="hidden" name="table[title]" value="My new title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  #   <% update_table(@table) do |form| %>
  #     <%= form.text_field :title %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #
  #   <form action="/tables/1" class="table update update_table" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="text" name="table[title]" value="My title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  def build_update_helper(resource)
    number_of_expected_args = number_of_args_expected_by_named_route_helper([resource.name_prefix, resource.singular].join)
    resource_is_singular = resource.is_a?(ActionController::Resources::SingletonResource)
    resource_is_plural = !resource_is_singular
    @module.module_eval <<-end_eval
      def update_#{resource.name_prefix}#{resource.singular}(*args, &block)
        if block_given?
          opts = args.extract_options!
          args_for_fields_for = ['#{resource.singular}']
          #{'args_for_fields_for.push(args.pop) if args.length > ' + number_of_expected_args.to_s if resource_is_singular}
          #{'args_for_fields_for.push(args.last)' if resource_is_plural}
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'update', *(opts.delete(:class) || '').split)
          concat(form_tag(#{resource.name_prefix}#{resource.singular}_path(*args), {:class => css_classnames, :method => :put}), block.binding)
          fields_for(*args_for_fields_for, &block)
          concat('</form>', block.binding)
        else
          opts = args.extract_options!
          if args.last.is_a?(Hash)
            resource_attributes = args.pop
          else #if only one hash is provided, it is assumed to be the resource attributes hash
            resource_attributes = opts
            opts = {}
          end
          label = opts.delete(:label) || 'Save'
          opts_for_button = {:type => 'submit'}
          opts_for_button[:title] = opts.delete(:title) if opts[:title]
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'update', *(opts.delete(:class) || '').split)
          content_tag('form', :method => :post, :action => #{resource.name_prefix}#{resource.singular}_path(*args), :class => css_classnames) do
            token_tag.to_s +
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join <<
            hidden_field_tag('_method', 'put', :id => nil) <<
            content_tag(:button, label, opts_for_button)
          end
        end
      end
    end_eval
  end
  
    
   # include the module (loaded with helper methods) into ActionView::Base
  def install_helpers
    ActionView::Base.send! :include, @module
  end
  
  # determine how many arguments a specific named route helper expects
  def number_of_args_expected_by_named_route_helper(helper_name)
    ActionController::Routing::Routes.named_routes.routes[helper_name.to_sym].segment_keys.size
  end
  
  
end


ActionController::Routing::RouteSet::Mapper.class_eval do
  
  def resources_with_resourceful_view_helpers(*entities, &block)
    resources_without_resourceful_view_helpers(*entities, &block)
    options = entities.extract_options!
    ResourcefulViews.new do |resourceful_views|
      entities.each do |entity|
        resource = ActionController::Resources::Resource.new(entity, options)
        resourceful_views.build_and_install_helpers_for_resource(resource)
      end
    end
  end
  
  alias_method_chain :resources, :resourceful_view_helpers
  
  def resource_with_resourceful_view_helpers(*entities, &block)
    resource_without_resourceful_view_helpers(*entities, &block)
    options = entities.extract_options!
    ResourcefulViews.new do |resourceful_views|
      entities.each do |entity|
        resource = ActionController::Resources::SingletonResource.new(entity, options)
        resourceful_views.build_and_install_helpers_for_singular_resource(resource)
      end
    end
  end
    
  alias_method_chain :resource, :resourceful_view_helpers
  
end

