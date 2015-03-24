# require gems needed to run pepdb, see Gemfile
require 'bundler'
Bundler.require

# run pepdb
require File.expand_path '../app.rb', __FILE__
run Sinatra::Application
