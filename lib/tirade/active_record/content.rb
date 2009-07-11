module Tirade
  module ActiveRecord
    module Content
      include ActsAs

      Scopes = %w(order limit skip recent with_later_than_now).freeze unless defined?(Scopes)

      def self.included(base)
        base.class_inheritable_reader :marked_up_fields
        base.class_inheritable_writer :marked_up_fields
        base.marked_up_fields = []
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      module ClassMethods
        def acts_as_content(opts={})
          Tirade::ActiveRecord::Content.register_class(self)
          acts_as! :content
          if table_exists? && column_names.include?('slug')
            acts_as! :slugged
            has_slug :prepend_id => false
          end
          if liquids = opts.delete(:liquid) + [:slug, :table_name]
            liquid_methods *liquids
          end
          named_scope :with_later_than_now, lambda { |f|
            if !f.blank?
              {:conditions => "#{sanitize_sql(f)} > NOW()"}
            else
              {}
            end
          }
          named_scope :limit, lambda { |l|
            if l.to_i != 0
              {:limit => l}
            else
              {}
            end
          }
          named_scope :skip, lambda { |s|
            if s.to_i != 0
              {:offset => s}
            else
              {}
            end
          }
          named_scope :recent, lambda { |num|
            if num.to_i != 0
              {:order => 'updated_at DESC', :limit => num}
            else
              {}
            end
          }
        end

        def controller_name
          name.underscore.pluralize
        end

        def markup(*fields)
          self.marked_up_fields << fields
          self.marked_up_fields.flatten!
          self.marked_up_fields.uniq!
        end

        def comparisons_grouped_by_column
          columns.inject({}) do |all_comps, col|
            comps = case col.type
              when :integer, :datetime
                %w( greater_than greater_than_or_equal_to equals less_than_or_equal_to less_than )
              when :string, :text
                %w( equals does_not_equal begins_with ends_with like )
              else
                []
              end
            all_comps.merge col.name => comps
          end
        end
      end

      module InstanceMethods
        def markup?(field)
          self.class.marked_up_fields.include?(field.to_sym)
        end
      end
    end
  end
end
