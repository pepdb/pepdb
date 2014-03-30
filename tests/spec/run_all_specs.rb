#!/usr/bin/env ruby
require File.expand_path('../../../app', __FILE__)
ENV['RACK_ENV'] = 'test'

def app
  Sinatra::Application
end

specs = ['testqrystrbuild.rb']
specs.each do |spec|
  #spec_path = File.dirname(__FILE__) + "/unit/#{spec}_spec.rb"
  spec_path = spec
  @output = %x[rspec2.0 #{spec_path}]
  puts @output
end
