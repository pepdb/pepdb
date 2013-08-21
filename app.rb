#pepdb.rb
require 'sinatra'
require 'date'
require 'sass'
require 'haml'
load 'model.rb'
load 'helpers.rb'

Haml::Options.defaults[:format] = :xhtml
Haml::Options.defaults[:hypenate_data_attrs] = false

set :app_file, __FILE__
set :root, File.dirname(__FILE__)

selection_columns = [:selection_name, :library_name, :date, :species, :tissue, :cell]
dataset_columns = [:dataset_name, :library_name, :selection_name, :date, :selection_round]

#before %r{.+\.js} do
#  content_type 'text/javascript'
#end

get '/' do
  haml :login
end

get '/*style.css' do
  scss :style
end

get '/libraries' do
  @libraries = Library.all
  haml :libraries
end

get '/libraries/:lib_name' do
  @libraries = Library.all
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  haml :libraries
end

get '/selections' do
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  haml :selections
end

get '/selections/:sel_name' do
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  haml :selections
end

get '/datasets' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  haml :datasets
end

get '/datasets/:set_name' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  @peptides = Peptide.join(Observation, :peptide_sequence=>:peptide_sequence).join(SequencingDataset, :dataset_name=>:dataset_name)
  haml :datasets
end
