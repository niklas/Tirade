require 'acts_as_pictureable'

ActiveRecord::Base.class_eval do
  include AlexPodaras::Acts::Pictureable
end
