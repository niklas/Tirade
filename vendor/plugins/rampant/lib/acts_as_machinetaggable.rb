module ActiveRecord
  module Acts #:nodoc:
    module Machinetaggable #:nodoc:
      module SingletonMethods
        # Pass a machinetag string, returns machinetaggables that match the machinetag string.
        # 
        # Options:
        #   :match - Match machinetaggables matching :all or :any of the machinetags, defaults to :any
        #   :user  - Limits results to those owned by a particular user
        def find_machinetagged_with(machinetags, options = {})
          options.assert_valid_keys([:match, :user])
          
          machinetags = Machinetag.parse(machinetags)
          return [] if machinetags.empty?
          
          group = "#{table_name}_machinetaggings.machinetaggable_id HAVING COUNT(#{table_name}_machinetaggings.machinetaggable_id) = #{machinetags.size}" if options[:match] == :all
          conditions = sanitize_sql(["#{table_name}_machinetags.name IN (?)", machinetags])
          conditions += sanitize_sql([" AND #{table_name}_machinetaggings.user_id = ?", options[:user]]) if options[:user]
          
          find(:all, 
            { 
              :select =>  "DISTINCT #{table_name}.*",
              :joins  =>  "LEFT OUTER JOIN machinetaggings #{table_name}_machinetaggings ON #{table_name}_machinetaggings.machinetaggable_id = #{table_name}.#{primary_key} AND #{table_name}_machinetaggings.machinetaggable_type = '#{name}' " +
                          "LEFT OUTER JOIN machinetags #{table_name}_machinetags ON #{table_name}_machinetags.id = #{table_name}_machinetaggings.machinetag_id",
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
        
        def user_id=(new_user_id)
          @new_user_id = User.find(new_user_id).id
        end
        
        def machinetag_list(user = nil)
          unless user
            machinetags.collect { |machinetag| machinetag.name.include?(" ") ? %("#{machinetag.name}") : machinetag.name }.join(" ")
          else
            machinetags.delete_if { |machinetag| !user.machinetags.include?(machinetag) }.collect { |machinetag| machinetag.name.include?(" ") ? %("#{machinetag.name}") : machinetag.name }.join(" ")
          end
        end
        
        def update_machinetags
          if @new_machinetag_list
            Machinetag.transaction do
              unless @new_user_id
                machinetaggings.destroy_all
              else
                machinetaggings.find(:all, :conditions => "user_id = #{@new_user_id}").each do |machinetagging|
                  machinetagging.destroy
                end
              end
            
              Machinetag.parse(@new_machinetag_list).each do |name|
                Machinetag.find_or_create_by_name(name).machinetag(self, @new_user_id)
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
