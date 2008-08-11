steps_for(:toolbox) do
  Then /the Toolbox (should|should not) (?:be |stay )?open(?: anymore)?/ do |yes_or_no|
    wait_for_ajax
    if yes_or_no == 'should'
      $browser.is_element_present("css=div#toolbox").should be_true
      $browser.is_visible("css=div#toolbox").should be_true
    else
      (
        !$browser.is_element_present("css=div#toolbox") ||
        !$browser.is_visible("css=div#toolbox")
      ).should be_true
    end
  end

  When 'submitting toolbox form $form' do |form|
    $browser.submit form
    wait_for_ajax
  end

  When /(he|she) closes the Toolbox/ do |_|
    $browser.click "css=div#toolbox_close"
    wait_for_effect
  end

  When /(she|he) opens accordion(?: item )? (\S+)/ do |_,item|
    $browser.click "css=div.frame.last h3.accordion_toggle.#{item}"
    sleep 1
    wait_for_effect
  end

  When /(he|she) clicks on toolbox link to (\w+) (\w+)/ do |_,action,controller|
    $browser.click "css=#toolbox div.frame.last a.#{action}.#{controller}"
    wait_for_ajax
    wait_for_effect
  end

  When /(he|she) clicks on toolbox button named (\w+)/ do |_,name|
    $browser.click %Q~css=#toolbox div.frame.last input[value="#{name}"]~
    wait_for_ajax
    wait_for_effect
  end
end
