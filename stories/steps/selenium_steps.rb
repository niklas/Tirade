steps_for(:selenium) do

  When "$actor opens browser" do |actor|
    unless $browser
      $browser = selenium_driver
      $browser.start
    end
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

  Then "$he_or_she should see $element" do |he_or_she, element|
    $browser.is_element_present("css=#{element}").should be_true
    $browser.is_visible("css=#{element}").should be_true
  end

  Then "page should include text: $text" do |text|
    # response.should have_text(/#{text}/)
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

  When "fills in $field with '$value'" do |field, value|  
    User.destroy_all
    $browser.type "css=##{field}", value 
  end  

  When "selects $field as '$option'" do |field, option|
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
