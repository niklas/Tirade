Factory.define :valid_user , :class => User do |u|
  u.login "alice"
  u.password "ultrasecret"
  u.password_confirmation "ultrasecret"
  u.email "alice@example.com"
end

Factory.define :invalid_user , :class => User do |u|
end
