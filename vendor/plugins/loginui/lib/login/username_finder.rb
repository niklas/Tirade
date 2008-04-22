module Login

  # An extremely simple module that allows me to put the logic for
  # determining the username is one place.
  module UsernameFinder

    # Will get the currently configured username field. If not defined
    # then email, then username, then user_name will be attempted.
    # If none of those fields exist then nil is returned which will
    # probably cause an error in the application.
    def username_field
      # Let the app specified field take presedence
      return User.username_field if User.respond_to? :username_field
 
      # Take a couple of guesses
      %w(email username user_name).find do |fld|
        User.column_names.include? fld
      end
    end
  end
end