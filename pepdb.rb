#pepdb.rb
require 'sinatra'

get '/' do
  haml :login
end
