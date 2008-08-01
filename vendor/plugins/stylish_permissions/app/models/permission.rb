class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  validates_uniqueness_of :app_method, :scope => :app_controller

  def self.grouped_by_controller
    all.group_by(&:app_controller)
  end

  def name
    "#{app_controller}/#{app_method}"
  end
end
