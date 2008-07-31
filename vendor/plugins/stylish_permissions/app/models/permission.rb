class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  def name
    "#{app_controller}/#{app_method}"
  end
end
