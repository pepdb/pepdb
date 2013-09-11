#pepdb.rb
require 'sinatra'
require 'sinatra/partial'
require 'date'
require 'sass'
require 'haml'
load 'model.rb'
load 'helpers.rb'

Haml::Options.defaults[:format] = :xhtml

set :app_file, __FILE__
set :root, File.dirname(__FILE__)

selection_columns = [:selection_name]
selection_all_columns = [:selection_name, :library_name, :date, :species, :tissue, :cell]
dataset_columns = [:dataset_name ]
dataset_info_columns = [:dataset_name, :library_name, :selection_name, :date]
dataset_all_columns = [:dataset_name, :library_name, :selection_name, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :species, :tissue, :cell, :statistics]
peptide_columns = [:peptides__peptide_sequence, :rank, :reads , :dominance]
sys_peptide_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name,:rank, :reads , :dominance]
cluster_peptide_columns = [:clusters_peptides__peptide_sequence, :rank, :reads , :peptides_sequencing_datasets__dominance]
peptide_all_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name, :selection_name, :library_name, :rank, :reads, :dominance, :performance, :species, :tissue, :cell ]
dna_columns = [:dna_sequences__dna_sequence, :reads]

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

get '/libraries/:lib_name/:sel_name' do
  @libraries = Library.all
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  @selection_info = Selection.join(Target, :target_id=>:target_id).select(*selection_all_columns)
  haml :libraries
end

get '/selections' do
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_all_columns)
  haml :selections
end

get '/selections/:sel_name' do
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_all_columns)
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  haml :selections
end

get '/selections/:sel_name/:set_name' do
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_all_columns)
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  @dataset_info = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_all_columns)
  haml :selections
end

get '/datasets' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_info_columns)
  haml :datasets
end

get '/datasets/:set_name' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_info_columns)
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  haml :datasets
end
  
get '/datasets/:set_name/:pep_seq' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_info_columns)
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  @peptide_dna = Peptide.join(DNAFinding, :peptide_sequence=>:peptide_sequence).join(SequencingDataset, :dataset_name =>:dataset_name).join(DNASequence, :dna_sequence=>:dna_sequences_peptides_sequencing_datasets__dna_sequence).select(*dna_columns)
  haml :datasets
end

get '/clusters' do
  @clusters = Cluster
  haml :clusters
end

get '/clusters/:sel_cluster' do
  @clusters = Cluster
  @cluster_info = Cluster.select(:consensus_sequence, :dominance, :parameters)
 @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  haml :clusters
end

get '/clusters/:sel_cluster/:pep_seq' do
  @clusters = Cluster
  @cluster_info = Cluster.select(:consensus_sequence, :dominance, :parameters)
 @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :clusters
end

get '/sys-search' do
  @libraries = Library.all
  @datasets = SequencingDataset.all
  @selections = Selection.all
  haml :sys_search
end

get '/sys-search/:pep_seq' do
  @libraries = Library.all
  @datasets = SequencingDataset
  @selections = Selection
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*sys_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :sys_search
end

post '/sys-search' do
  @libraries = Library.all
  @datasets = SequencingDataset
  @selections = Selection
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*sys_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :sys_search
end

get '/prop-search' do
  @libraries = Library
  @datasets = SequencingDataset
  @selections = Selection
  @targets = Target
  @results = Peptide.join(Observation, :peptide_sequence => :peptide_sequence).join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).join(Target, :selections__target_id___target => :targets__target_id___target)
  @querystring, @placeholders = build_property_array(params)
  haml :prop_search
end

get '/comp-search' do
  @libraries = Library.all
  @datasets = SequencingDataset
  @selections = Selection
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*sys_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :comp_search

end

post '/checklist' do
  @data_to_display, @column, @section = choose_data(params)
  @section = params['sec']
  haml :checklist, :layout => false
end

post '/radiolist' do
  @data_to_display = SequencingDataset.select(:dataset_name).where(:selection_name => params['checkedElem'])
  @column = :dataset_name
  haml :radiolist, :layout => false
end

post 'peptide_results' do
  

  haml :peptide_results, :layout => false
end
