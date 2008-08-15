module ActiveRecord
  module Acts #:nodoc:
    module Machinetaggable #:nodoc:
      module SingletonMethods
        # Pass a machinetag string, returns machinetaggables that match the machinetag string.
        # 
        # Options:
        #   :match - Match machinetaggables matching :all or :any of the machinetags, defaults to :any
        #   :user  - Limits results to those owned by a particular user
        def find_machinetagged_with(tag_string, options = {})
          options.assert_valid_keys([:match, :user])

          conditions = Machinetag.conditions_from_string(tag_string, options)
          return [] if conditions.blank?
          
          this_taggings = "#{table_name}_machinetaggings"
          this_tags = "#{table_name}_machinetags"
          
          conditions += sanitize_sql([" AND #{this_taggings}.user_id = ?", options[:user]]) if options[:user]
          group = "#{this_taggings}.machinetaggable_id HAVING COUNT(#{this_taggings}.machinetaggable_id) = #{machinetags.size}" if options[:match] == :all

          find(:all, 
            { 
              :select =>  "DISTINCT #{table_name}.*",
              :joins  =>  "LEFT OUTER JOIN machinetaggings #{this_taggings} ON #{this_taggings}.machinetaggable_id = #{table_name}.#{primary_key} AND #{this_taggings}.machinetaggable_type = '#{name}' " +
                          "LEFT OUTER JOIN machinetags #{this_tags} ON #{this_tags}.id = #{this_taggings}.machinetag_id",
              :conditions => conditions,
              :group  =>  group
            })
        end
        
        # Pass a machinetag string, returns machinetaggables that match the machinetag string for a particular user.
        # 
        # Options:
        #   :match - Match machinetaggables matching :all or :any of the machinetags, defaults to :any
        def find_machinetagged_with_by_user(machinetags, user, options = {})
          options.assert_valid_keys([:match])
          find_machinetagged_with(machinetags, {:match => options[:match], :user => user})
        end
      end
      
      module InstanceMethods
        def machinetag_list=(new_machinetag_list)
          unless machinetag_list == new_machinetag_list
            @new_machinetag_list = new_machinetag_list
          end
        end
        
        # FIXME this may break other functionality, srsly
        def user_id=(new_user_id)
          @new_user_id = User.find(new_user_id).id
        end
        
        def machinetag_list(user = nil)
          unless user
            machinetags
          else
            machinetags.delete_if { |machinetag| !user.machinetags.include?(machinetag) }
          end.collect(&:full_name).join(" ")
        end
        
        def update_machinetags
          if @new_machinetag_list
            Machinetag.transaction do
              unless @new_user_id
                machinetaggings.destroy_all
              else
                machinetaggings.for_user(@new_user_id).each do |machinetagging|
                  machinetagging.destroy
                end
              end
            
              Machinetag.new_from_string(@new_machinetag_list).each do |tag|
                Machinetag.find_or_create_by_full_name(tag.full_name).apply_to!(self, @new_user_id)
              end

              machinetags.reset
              machinetaggings.reset
              @new_machinetag_list = nil
            end
          end
        end
      end
    end
  end
end
