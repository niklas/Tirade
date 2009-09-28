require 'acts_as_paperclipped'

ActiveRecord::Base.class_eval do
  include Tirade::Acts::Paperclipped
end
