steps_for(:selenium) do

  Given /a(n| fresh) open browser window/ do |fresh_or_not|
    unless $browser
      $browser = selenium_driver
      $browser.start
    end
    if fresh_or_not =~ /fresh/
      $browser.delete_all_visible_cookies
    end
  end

  Given  "gone to $path" do |path|   
    $browser.open('http://localhost:4000' + path)    
  end    

  When "$actor goes to $path" do |actor, path|   
    $browser.open('http://localhost:4000' + path)    
  end    

  When "$actor looks at Page" do |actor|
    # placeholder
  end

  Then "$actor should see the $resource show page" do |actor, resource|
    # response.should render_template("#{resource.gsub(" ","_").pluralize}/show")
  end
         
  Then "$actor should see the $resource index page" do |actor, resource|
    # response.should render_template("#{resource.gsub(" ","_").pluralize}/index")
  end

  # Pass the params as such: ISBN: ‘0967539854′ and comment: ‘I love this book’ and rating: ‘4′
  # this matcher will post to the resource’s default create action
  When "$actor submits $a_or_an $resource with $attributes" do |actor, a_or_an, resource, attributes|
    # post_via_redirect "/#{resource.downcase.pluralize}", {resource.downcase => attributes.to_hash_from_story}
  end

  Then /(he|she) (should|should not) see element(?::)? (.*)/ do |_, yes_or_no, selector|
    if yes_or_no == 'should'
      $browser.is_element_present("css=#{selector}")
      $browser.is_visible("css=#{selector}").should be_true
    else
      (
        !$browser.is_element_present("css=#{selector}") ||
        !$browser.is_visible("css=#{selector}")
      ).should be_true
    end
  end

  Then /(he|she) (should|should not) see link to (\w+) (\w+)/ do |_, yes_or_no, action, controller|
    selector = "a.#{action}.#{controller}"
    if yes_or_no == 'should'
      $browser.is_element_present("css=#{selector}")
      $browser.is_visible("css=#{selector}").should be_true
    else
      (
        !$browser.is_element_present("css=#{selector}") ||
        !$browser.is_visible("css=#{selector}")
      ).should be_true
    end
  end

  Then /(he|she) should see field (\w+) filled with '(.*)'/ do |_, field_name, content|
    selector = "css=##{field_name}"
    $browser.is_element_present(selector).should be_true
    $browser.get_value(selector).should == content
  end

  Then /(he|she) (should|should not) see text(?::)? (.*?)/ do |_, yes_or_no, text|
    if yes_or_no == 'should'
      $browser.is_text_present(text).should be_true
    else
      $browser.is_text_present(text).should_not be_true
    end
  end

  Then "page should include a notice ‘$notice_message’" do |notice_message|
    # response.should have_tag("div.notice", notice_message)
  end

  Then "page should have the $resource’s $attributes" do |resource, attributes|
    # actual_resource = instantize(resource)
    # attributes.split(/, and |, /).each do |attribute|
    #   response.should have_text(/#{actual_resource.send(attribute.strip.gsub(" ","_"))}/)
    # end 
  end
  
  When "clicks on '$link'" do |link|
    $browser.click "link=#{link}"
    $browser.wait_for_page_to_load
  end

  When /(he|she) clicks on (remote link|link) to (\w+) (\w+)/ do |_,remote_or_not,action,controller|
    $browser.click "css=a.#{action}.#{controller}"
    if remote_or_not =~ /remote/
      wait_for_ajax
    else
      $browser.wait_for_page_to_load
    end
  end

  When /(he|she) clicks on (remote button|button) named (\w+)/ do |_,remote_or_not,name|
    $browser.click "name=commit value=#{name}"
    if remote_or_not =~ /remote/
      wait_for_ajax
    else
      $browser.wait_for_page_to_load
    end
  end

  When /filling in (\S+) with "(.*)"/ do |field, value|  
    $browser.type "css=##{field}", value 
  end  

  When "selecting $field as '$option'" do |field, option|
    #selects option, :from => field
  end

  When "checks $checkbox" do |checkbox|
    #checks checkbox
  end

  Then "$actor closes browser" do |actor|
    $browser.stop
  end 
  
  When "submits $form" do |form|
    $browser.submit form
  end

end
