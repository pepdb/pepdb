### Preconditions
Given(/^The user checks "(.*?)" checkbox$/) do |arg1|
  page.check(arg1)
end

Given(/^The user selects "(.*?)" as "(.*?)"$/) do |arg1, arg2|
  page.select arg1, :from => arg2
end

Given(/^The user chooses "(.*?)" radiobutton$/) do |arg1|
  page.choose arg1
end

### Actions
When(/^The user clicks "(.*?)" and selects peptide "(.*?)" from the results$/) do |arg1, arg2|
  click_button(arg1)
  @javascript
  find('#pep_table').find('td', :text => arg2).click
end

When(/^The user clicks "(.*?)" and selects peptide "(.*?)" from the similar sequences$/) do |arg1, arg2|
  click_button(arg1)
  @javascript
  find('#prop_table').find('td', :text => arg2).click
end

When(/^The user clicks "(.*?)" and selects peptide "(.*?)" from the peptide comparison$/) do |arg1, arg2|
  click_button(arg1)
  @javascript
  find('#comppep_table').find('td', :text => arg2).click
end

When(/^The user finally checks "(.*?)" checkbox$/) do |arg1|
  page.check(arg1)
end


### Results
Then(/^The text "(.*?)" should show up "(.*?)" times$/) do |arg1, arg2|
  page.has_text?(arg1, :count => arg2)
end
