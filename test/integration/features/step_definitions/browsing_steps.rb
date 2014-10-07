### Preconditions
Given(/^The user first selects library "(.*?)"$/) do |arg1|
  find('#select_table').find('td', :text => arg1).click
end

Given(/^The user then selects selection "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end

Given(/^The user first selects selection "(.*?)"$/) do |arg1|
  find('#select_table').find('td', :text => arg1).click
end

Given(/^The user then selects sequencing dataset "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end

Given(/^The user first selects sequencing dataset "(.*?)"$/) do |arg1|
  find('#select_table').find('td', :text => arg1).click
end

Given(/^The user selects cluster "(.*?)" in library "(.*?)", selection "(.*?)" and dataset "(.*?)"$/) do |arg1, arg2, arg3, arg4|
  #page.execute_script("$('#clusterlist').open_node('#{arg2}')")
  page.execute_script("$('#clusterlist').jstree('open_all')")
  click_link(arg1)
end
### Actions
When(/^The user finally selects library "(.*?)"$/) do |arg1|
  find('#select_table').find('td', :text => arg1).click
end

When(/^The user finally selects selection "(.*?)"$/) do |arg1|
  @javascript
  find('#select_table').find('td', :text => arg1).click
end

When(/^The user finally chooses sequencing datasets "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end

When(/^The user finally chooses selection "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end

When(/^The user finally selects sequencing datasets "(.*?)"$/) do |arg1|
  @javascript
  find('#select_table').find('td', :text => arg1).click
end

When(/^The user finally chooses peptide "(.*?)"$/) do |arg1|
  @javascript
  find('#pep_table').find('td', :text => arg1).click
end

When(/^The user finally selects peptide "(.*?)"$/) do |arg1|
  @javascript
  find('#show_table').find('td', :text => arg1).click
end
### Results
Then(/^The node "(.*?)" should not show up$/) do |arg1|
  page.has_no_content?(arg1)
end



