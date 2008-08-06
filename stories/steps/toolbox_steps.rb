steps_for(:toolbox) do
  Then 'the Toolbox should open' do
    wait_for_ajax
    $browser.is_element_present("css=div#toolbox")
    $browser.is_visible("css=div#toolbox")
  end
end
