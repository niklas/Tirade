namespace :tirade do
  namespace :permissions do
    desc "Syncs Permissions for all Resources"
    task :sync => [:environment] do
      Permission.transaction do
        Permission.update_all(:processed => false)
        routes_by_controller = ActionController::Routing::Routes.routes.group_by {|r| r.defaults[:controller]}.
          reject {|c,r| c=~%r~/~ }.
          reject {|c,r| %w(stylesheets sessions javascripts).include? c }.
          select { |c,r| c=~%r~s$~ }
        routes_by_controller.each do |cont, routes|
          routes.collect {|r| r.defaults[:action]}.uniq.each do |action|
            print "#{cont}/#{action}: "
            if permission = Permission.find_by_app_controller_and_app_method(cont,action)
              permission.processed = true
              permission.save!
              puts "found."
            else
              Permission.create!(
                :app_controller => cont,
                :app_method => action,
                :processed => true
              )
              puts "created."
            end
          end
        end
        Permission.find_all_by_processed(false).each do |p| 
          p.destroy!
          puts "Destroying #{p.name}"
        end
      end
    end
  end
end
