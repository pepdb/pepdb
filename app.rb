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
  @output1 = Library.all
  @output2 = Selection.join_table(:inner, :targets, :target_id=>:target_id).select(:selection_name, :library_name, :date, :species, :tissue, :cell)
  haml :output
end

get '/selections' do
  @output1 = Selection.join_table(:inner, :targets, :target_id=>:target_id).select(:selection_name, :library_name, :date, :species, :tissue, :cell)
  @output2 = SequencingDataset.all
  haml :output
end

