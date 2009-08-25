namespace :tirade do
  namespace :setup do
    desc "Creates a user named 'admin' if no user is found and give him admin rights"
    task :admin => :environment do
      user = User.first
      unless user
        password = "changeme"
        user = User.create! :login => 'admin', :email => 'admin@example.com', :password => password, :password_confirmation => password
        puts "Created admin user. You can log in with admin:#{password}. Please change it immediately!"
      end
      Lockdown::System.make_user_administrator(user)
      puts "User '#{user.login}' is admin now!"
    end
  end
end
