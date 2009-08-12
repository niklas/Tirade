Factory.define :valid_user , :class => User do |u|
  u.sequence(:login) {|i| "alice#{i}"}
  u.password "ultrasecret"
  u.password_confirmation "ultrasecret"
  u.sequence(:email) {|i| "alice#{i}@example.com" }
end

Factory.define :invalid_user , :class => User do |u|
end
