require "acts_as_configurable"
require "acts_as_configurable_helper"
ActiveRecord::Base.send(:include, ActsAsConfigurable)
ActionView::Helpers::FormBuilder.send(:include, ActsAsConfigurable::FormBuilder)
