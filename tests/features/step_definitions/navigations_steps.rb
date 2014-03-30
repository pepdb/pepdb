Given(/^The user is not logged in$/) do
  visit '/logout'
end

When(/^The user opens 'libraries'$/) do
  visit '/libraries'
end

Then(/^The login page should show up$/) do
  page.has_content?('Please login')
end

Given(/^The user visits the main page$/) do
  visit '/'
end

Given(/^The user fills "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  fill_in(arg1, :with => arg2)
end

When(/^The user clicks "(.*?)"$/) do |arg1|
  click_button(arg1)
end

Then(/^The welcome page should show up$/) do
  page.has_content?('Welcome to pepDB!')
end

Then(/^The message "(.*?)" should show up$/) do |arg1|
  page.has_content?(arg1)
end

Given(/^The user opens "(.*?)"$/) do |arg1|
  visit arg1
end

When(/^The user selects library "(.*?)"$/) do |arg1|
  find('#select_table').find('td', :text => arg1).click
end

Then(/^The "(.*?)" should show up$/) do |arg1|
  page.has_content?(arg1)
end

Given(/^The user "(.*?)" is logged in with "(.*?)"$/) do |arg1, arg2|
  visit '/logout'
  fill_in("username", :with => arg1)
  fill_in("password", :with => arg2)
  click_button("Login")
end

When(/^The user selects selection "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end

