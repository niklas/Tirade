# This controller is called "Profiles" instead of "Users" even though we
# are manipulating a User object.
#
# The rational is we need a controller that the user can interact with
# where all actions refer to the current user. This is different from
# an applications own needs to have a controller to manage multiple
# users (say for an admin interface or social networking app).
#
# Therefore we have used the term Profile because it seems more
# descriptive and doesn't conflict with a UsersController that the app
# might have itself.
class ProfilesController < ApplicationController
  include Login::UsernameFinder
  authentication_required :except => [:new, :create]

  # User registration form. If you want to provide default values in
  # your application override this method. Obviously override the
  # template to add more fields the the registration form.
  def new
    @user = User.new
  end

  # Process user registration form or restore existing user (either way
  # we are creating a user that didn't exist from the applications point
  # of view).
  #
  # If verified_at is defined on the model but nil after save then a
  # account verification message is sent to verify the email given.
  # Also the field "email" must exist on the model for the email
  # verification feature to work.
  #
  # If you want a "Welcome" letter but don't want to enforce an
  # email verification procedure then consider installing a after_filter
  # that looks something like this:
  #
  #    after_filter :welcome_new_user
  #    private
  #    def welcome_new_user
  #      Notifications.deliver_welcome_letter(@user) unless @user.new_record?
  #    end
  #
  # If you want to include their password for reference this is your
  # one chance since after this method their password will be just
  # a hash. To implement just change the above line to:
  #
  #    @user.password = params[:user][:password]
  #    Notifications.deliver_welcome_letter(@user) unless @user.new_record?
  #
  # With the above code the user object will have an un-encrypted
  # password at "@user.password" that you can use.
  #
  # We are restoring a user if the following is true:
  # * The user already exists
  # * There is a :delete_at field and it has a value
  # * The URL has a token that will authenticate against that user
  def create
    # For compatiblity with acts_as_paraniod.
    find_meth = if User.respond_to? :find_with_deleted
        :find_with_deleted
      else
        :find
      end

    @user = User.send find_meth, :first, :conditions =>
      {username_field.to_sym => params[:user][username_field.to_sym]}

    restoring = !@user.nil? && @user.respond_to?(:deleted_at) &&
      !@user.deleted_at.nil?
    restoring = false unless !params[:token].blank? &&
      @user.authenticate(params[:token].split(';').last)

    # If restoring then they can onyl be restored. All other params
    # are ignored.
    if restoring
      @user.deleted_at = nil
    else
      @user = User.new params[:user]
    end

    if @user.save

      flash[:notice] = if restoring
        "#{@user} successfully restored"
      else
        "#{@user} successfully registered"
      end

      if @user.respond_to?(:verified_at) && @user.respond_to?(:email)
        @user.reload
        if @user.verified_at.nil?
          ProfileNotifications.deliver_signup_verification @user,
            email_token(@user, 'verification', :action => 'update',
            :verified => true)
          # The verification_sent tell them the same thing
          flash[:notice] = nil

          render :action => 'verification_sent' and return
        end
      end

      session[:uid] = @user.id
      redirect_to home_url
    else
      render :template => (params[:_registration_form] || 'profiles/new')
    end
  end

  # Update current user with new info. Primarily used for account
  # verification. If the "edit" method exists then this action is
  # assuming the application has implemented a feature to allow users
  # to update their account info. It will therefore use that when
  # redirecting or rendering for errors. If not then it will simply
  # redirect the user/home when successful or raise an exception when
  # not successful.
  def update
    @user = current_user
    @user.verified_at = Time.now if
      @user.respond_to?(:verified_at) && !params[:verified].blank?
    if @user.update_attributes params[:user]
      flash[:notice] = if params[:verified]
        "Verified E-mail address for #{@user}"
      else
        "Successfully updated #{@user}"
      end
      redirect_to respond_to?(:edit) ?
        (params[:_update_success_path] || {:action => 'edit'}) : home_url
    else
      if respond_to? :edit
        render :action => 'edit'
      else
        raise ActiveRecord::ActiveRecordError.new("Failed to save #{@user}")
      end
    end
  end

  # Let a user remove theirselves. If the model looks like it supports
  # account re-activiation (has a email address field and deleted_at
  # field) then it will simply be marked deleted and not actually
  # removed.
  def destroy

    token = email_token current_user, 'reactivation', :action => 'create',
      :user => {username_field.to_sym => current_user.send(username_field.to_sym)}
    ProfileNotifications.deliver_reactivate_account current_user, token if
      current_user.respond_to?(:email) && current_user.respond_to?(:deleted_at)

    flash[:notice] = "Successfully deleted user #{current_user}"
    if current_user.respond_to? :deleted_at
      current_user.deleted_at = Time.now
      current_user.save!
    else
      current_user.destroy
    end

    redirect_to logout_url
  end

  private

  def email_token(user, purpose, params)
    token = user.assign_token purpose
    user.save!
    token = "#{user.id};#{token}"
    url_for params.merge(:token => token)
  end
end
