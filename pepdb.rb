#pepdb.rb
require 'sinatra'
require 'date'
require 'sass'
require 'haml'
load 'model.rb'

get '/' do
  haml :login
end

get '/main' do
  haml :main
end

get '/style.css' do
  scss :style
end

get '/libraries' do
  haml :main
end


