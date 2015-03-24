Given(/^The user selects to add "(.*?)"$/) do |arg1|
  page.select arg1, :from => :datatype
end

Given(/^The user enters all relevant data for "(.*?)"$/) do |arg1|
  page.fill_in("name", :with => arg1)
end

When(/^The user saves without errors$/) do
  click_button("add")
  within_frame 'notify' do
    has_content?("nasty")
  end
  #browser = page.driver.browser
  #rowser.switch_to.frame('notify')
  #page.has_content?('affenvater')
  #browser.switch_to.default_content
  #page.find("button", :text => /add.*/).click
  #page.has_no_content?("Success! All data inserted successfully!")
  #page.has_content?("affenvater")
end

Then(/^"(.*?)" should show up under "(.*?)"$/) do |arg1, arg2|
  visit arg2
  page.has_content?(arg1)
end

When(/^The user saves$/) do
  click_button("add")
end
