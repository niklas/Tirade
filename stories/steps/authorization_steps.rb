steps_for(:authorization) do
  Given "$actor logged in as $user_name" do |actor,user_name|
    @user = User.find_by_login(user_name)
    $browser.start
    $browser.open '/login'
    $browser.type 'login', user_name
    $browser.type 'password', 'test'
    $browser.click 'css=input.submit'
    $browser.wait_for_page_to_load
    $browser.is_text_present('Logged in as quentin').should be_true
  end

  Given /(\w+) is (?:an )?admin/ do |actor|
    @user.should be_is_admin
  end

  Given "$actor has role $role_name" do |actor,role_name|
    @user.role.should include(roles(:admin))
  end
end
