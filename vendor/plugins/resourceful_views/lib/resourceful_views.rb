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
  
  # Builds the 'index_[resource]' helper
  # 
  # === Examples
  # 
  #   <% index_books %>
  #
  #   renders:
  # 
  #   <a href="/books" class="index books index_books">Index</a>
  #
  #   <% index_books(:label => 'List') %>
  #
  #   renders:
  #
  #   <a href="/books" class="index books index_books">List</a>
  # 
  def build_index_helper(resource)
    @module.module_eval <<-end_eval
      def index_#{resource.name_prefix}#{resource.plural}(*args)
        opts = args.extract_options!
        link_to_opts = {}
        label = opts.delete(:label) || 'Index'
        custom_class = opts.delete(:class) || ''
        link_to_opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.plural}', 'index', *custom_class.split)
        link_to_opts[:title] = opts.delete(:title) if opts[:title]
        args << opts unless opts.empty? #excess options are passed on to named route helper
        link_to(label, #{resource.name_prefix}#{resource.plural}_path(*args), link_to_opts)
      end
    end_eval
  end
  
  
  
  # Builds the 'search_[resource]' helper
  # 
  # === Examples
  # 
  #   <% search_books %>
  #
  #   renders:
  # 
  #   <form action="/books" method="get" class="index books index_books search search_books">
	#	    <input type="text" name="query" />
	# 	  <button type="submit">Search</button>
	#   </form>
  #
  #   <% search_books(:label => 'Find') %>
  # 
  #   renders:
  # 
  #   <form action="/books" method="get" class="index books index_books search search_books">
	#	    <input type="text" name="query" />
	# 	  <button type="submit">Find</button>
	#   </form>
  #   
  def build_search_helper(resource)
    @module.module_eval <<-end_eval
      def search_#{resource.name_prefix}#{resource.plural}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Search'
        custom_class = opts.delete(:class) || ''
        content_tag('form', :action => #{resource.name_prefix}#{resource.plural}_path(*args), :method => :get, :class => ResourcefulViews.resourceful_classnames('#{resource.plural}', 'search', *custom_class.split)) do
          text_field_tag(:query, @query, :id => nil) +
          content_tag(:button, label, :type => 'submit')
        end
      end
    end_eval
  end
  
  # Builds the 'show_[resource](resource)' helper
  # 
  # === Examples
  # 
  #   <% show_book(@book) %>
  #
  #   renders:
  # 
  #   <a href="/books/1" class="show book show_book">Show</a>
  #
  #   <% show_book(@book, :label => @book.title) %>
  # 
  #   renders:
  # 
  #   <a href="/books/1" class="show book show_book">My book title</a>
  #
  def build_show_helper(resource)
    @module.module_eval <<-end_eval
      def show_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Show'
        custom_class = opts.delete(:class) || ''
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'show', *custom_class.split)
        link_to(label, #{resource.name_prefix}#{resource.singular}_path(*args), opts)
      end
    end_eval
  end


  
  # Builds the 'new_[resource]' helper
  # 
  # === Examples
  # 
  #   <% new_book %>
  #
  #   renders:
  # 
  #   <a href="/books/new" class="new book new_book">New</a>
  #
  #   <% new_book(:label => 'Add a book') %>
  # 
  #   renders:
  # 
  #   <a href="/books/new" class="new book new_book">Add a book</a>
  #
  def build_new_helper(resource)
    @module.module_eval <<-end_eval
      def new_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'New'
        custom_class = opts.delete(:class) || ''
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'new', *custom_class.split)
        link_to(label, new_#{resource.name_prefix}#{resource.singular}_path(*args), opts)
      end
    end_eval
  end


  
  # Builds the 'edit_[resource](resource)' helper
  # 
  # === Examples
  # 
  #   <% edit_book(@book) %>
  #
  #   renders:
  # 
  #   <a href="/books/1/edit" class="edit book edit_book">Edit</a>
  #
  #   <% edit_book(@book, :label => 'Change') %>
  # 
  #   renders:
  # 
  #   <a href="/books/1/edit" class="edit book edit_book">Change</a>
  #
  def build_edit_helper(resource)
    @module.module_eval <<-end_eval
      def edit_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Edit'
        custom_class = opts.delete(:class) || ''
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'edit', *custom_class.split)
        link_to(label, edit_#{resource.name_prefix}#{resource.singular}_path(*args), opts)
      end
    end_eval
  end


  
  # Builds the 'destroy_[resource](resource)' helper
  # 
  # === Examples
  # 
  #   <% destroy_book(@book) %>
  #
  #   renders:
  # 
  #   <form action="/books/1" class="book destroy destroy_book" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit">Delete</button>
  #   </form>
  #
  #   <% destroy_book(@book, :label => 'Remove') %>
  # 
  #   renders:
  # 
  #   <form action="/books/1" class="book destroy destroy_book" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit">Remove</button>
  #   </form>
  #
  def build_destroy_helper(resource)
    @module.module_eval <<-end_eval
      def destroy_#{resource.name_prefix}#{resource.singular}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Delete'
        custom_class = opts.delete(:class) || ''
        content_tag('form', :action => #{resource.name_prefix}#{resource.singular}_path(*args), :method => :post, :class => ResourcefulViews.resourceful_classnames('#{resource.singular}', 'destroy', *custom_class.split)) do
          hidden_field_tag(:_method, :delete, :id => nil) +
          content_tag(:button, label, :type => 'submit')
        end
      end
    end_eval
  end
  


  # Builds the list helpers
  #
  # === Examples
  #
  #   <% book_list do %>...<%- end -%>
  # 
  #   renders:
  # 
  #   <ul class="book_list">...</ul>
  # 
  #   <% the_book_list do %>..<% end %>
  # 
  #   renders:
  # 
  #   <ul id="book_list">...</ul>
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
  #   <% create_book(:title => 'My title') %>
  #
  #   renders:
  #
  #   <form action="/books" class="book create create_book" method="post">
  #     <input type="hidden" type="book[title]" value="My title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  # If only the last argument is a hash (as above), it is interpreted as the attribute hash for the model.
  # If the last two arguments are hashes, the first is interpreted as the attribute hash, the second as the options hash:
  #
  #   <% create_book({:title => 'My title'}, :label => 'Create') %>
  #   
  #   renders:
  # 
  #   <form action="/books" class="book create create_book" method="post">
  #     <input type="hidden" type="book[title]" value="My title" />
  #     <button type="submit">Create</button>
  #   </form>
  #
  # This means that if you want to pass only an options hash, you need to use an empty (attributes-)hash as the first argument:
  #
  #   <% create_book({}, :label => 'Create') %>
  #   
  #   renders:
  #
  #   <form action="/books" class="book create create_book" method="post">
  #     <button type="submit">Create</button>
  #   </form>   
  #
  # == Examples with block
  #
  #   <% create_book do |form| %>
  #     <%= form.text_field :title %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #   
  #   renders:
  #
  #   <form action="/books" class="book create create_book" method="post">
  #     <input type="text" type="book[title]" value="My title" />
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
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'create', *(opts.delete(:class) || '').split)
          content_tag('form', :method => :post, :action => #{resource.name_prefix}#{resource.plural}_path(*args), :class => css_classnames) do
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join <<
            content_tag(:button, label, :type => 'submit')
          end
        end
      end  
    end_eval
  end
  


  # Build the 'update_[resource](resource)' helper
  #
  # == Examples
  #
  #   <% update_book(@book, :title => 'My new title') %>
  #
  #   renders:
  #
  #   <form action="/books/1" class="book update update_book" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="hidden" name="book[title]" value="My new title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  #   <% update_book(@book) do |form| %>
  #     <%= form.text_field :title %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #
  #   <form action="/books/1" class="book update update_book" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="text" name="book[title]" value="My title" />
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
          css_classnames = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'update', *(opts.delete(:class) || '').split)
          content_tag('form', :method => :post, :action => #{resource.name_prefix}#{resource.singular}_path(*args), :class => css_classnames) do
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join <<
            hidden_field_tag('_method', 'put', :id => nil) <<
            content_tag(:button, label, :type => 'submit')
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

