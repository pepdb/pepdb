#pepdb.rb
require 'sinatra'

load 'model.rb'

get '/' do
  haml :login
end
