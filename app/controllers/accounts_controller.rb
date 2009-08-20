class AccountsController < ManageResourceController::Base

  def model_name
    'user'
  end
  private
  def object
    current_user
  end
  def collection
    raise "cannot have multiple accounts"
  end
end
