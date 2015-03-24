# require gems needed to run pepdb, see Gemfile
require 'bundler/setup'
Bundler.setup(:default)

# run pepdb
require File.expand_path '../app.rb', __FILE__
run Sinatra::Application
