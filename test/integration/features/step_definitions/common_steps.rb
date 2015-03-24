### Preconditions
Given(/^The user is not logged in$/) do
  visit '/logout'
end

Given(/^The user visits the main page$/) do
  visit '/'
end

Given(/^The user fills "(.*?)" with "(.*?)"$/) do |arg1, arg2|
  fill_in(arg1, :with => arg2)
end

Given(/^The user opens "(.*?)"$/) do |arg1|
  visit arg1
end

Given(/^The user "(.*?)" is logged in with "(.*?)"$/) do |arg1, arg2|
  visit '/logout'
  fill_in("username", :with => arg1)
  fill_in("password", :with => arg2)
  click_button("Login")
end

### Actions

When(/^The user clicks "(.*?)"$/) do |arg1|
  click_button(arg1)
end

### Results

Then(/^The login page should show up$/) do
  page.has_content?('Please login')
end

Then(/^The main page should show up$/) do
  page.has_content?('Welcome to pepDB!')
end

Then(/^The text "(.*?)" should show up$/) do |arg1|
  page.has_content?(arg1)
end

Then(/^The row "(.*?)" should not show up$/) do |arg1|
  row = find('#select_table').has_no_text?(arg1)
end

Then(/^The text "(.*?)" should not show up$/) do |arg1|
  page.has_no_content?(arg1)
end

Then(/^The welcome page should show up$/) do
  page.has_content?("Welcome to pepDB!")
end

Then(/^The message "(.*?)" should show up$/) do |arg1|
  page.has_content?(arg1)
end

