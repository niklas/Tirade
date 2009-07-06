module HasFulltextSearch
  def self.included(base)
    base.extend HasFulltextSearch::LikeSearch::ClassMethods
  end
  module LikeSearch
    module ClassMethods
      def has_fulltext_search(*args)
        #unless args.first.is_a?(Hash)
        #  name = args.shift
        #  search_name = "#{name}_search"
        #  fields_variable_name = "@#{name}_searchable_fields"
        #else
        #  search_name = "search"
        #end
        if not args.empty? and args.first != :all
          @searchable_fields = args.collect { |f| f.to_s }
        end
        class_eval do
          extend HasFulltextSearch::LikeSearch::Parsing
          extend HasFulltextSearch::LikeSearch::SingletonMethods
          scoping_method = self.respond_to?(:named_scope) ? :named_scope : :has_finder
          send scoping_method, :fulltext_search, lambda {|query|
            #query = args.shift
            if query.blank?
              {}
            else
              query.strip!
              fields = searchable_fields
              #fields -= options[:except] if options[:except]
              fields.map! { |f| "lower(#{f})" }
              {:conditions => build_text_condition(fields, query.downcase)}
            end
          }
        end
      end
    end
    module SingletonMethods
      # Return the default set of fields to search on
      def searchable_fields(tables = nil, klass = self)
        # If the model has declared what it searches_on, then use that...
        return @searchable_fields unless @searchable_fields.nil?

        # ... otherwise, use all text/varchar fields as the default
        fields = []
        tables ||= []

        string_columns = klass.columns.select { |c|
          c.type == :text or c.type == :string
        }
        
        fields = string_columns.collect { |c|
          klass.table_name + "." + c.name
        }

        if not tables.empty?
          tables.each do |table|
            klass = eval table.to_s.classify
            fields += searchable_fields([], klass)
          end
        end

        return fields
      end

      private
      def build_text_condition(fields, text)
        build_tc_from_tree(fields, demorganize(parse(text)))
      end

    end
    module InstanceMethods
    end
  end
end
