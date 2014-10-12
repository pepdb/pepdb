ENV['RACK_ENV'] = 'test'

require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'

require File.expand_path '../../../../../app.rb', __FILE__
Capybara.app = Sinatra::Application
#Capybara.default_driver = :selenium

# execute database rollback after every scenario
Around do |scenario, block|
  DB.transaction(:rollback => :always) do
    block.call
  end
end 
