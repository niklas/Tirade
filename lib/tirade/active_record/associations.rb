module Tirade
  module ActiveRecord
    module Associations
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def robustify_has_many(association_id)
          if (reflection = reflect_on_association(association_id)) && reflection.macro == :has_many
            idmeth = "#{reflection.name.to_s.singularize}_ids"
            class_eval <<-EODEF
              def #{idmeth}_with_robustness=(dirty_ids)
                clean_ids = dirty_ids.collect(&:to_i).compact.select(&:nonzero?).uniq
                if clean_ids != #{idmeth}
                  self.#{idmeth}_without_robustness = clean_ids
                end
              end
              alias_method_chain :#{idmeth}=, :robustness
            EODEF
          end
        end
      end
    end
  end
end
