#pepdb.rb
require 'sinatra'
require 'sinatra/partial'
require './modules/querystringbuilder'
require './modules/formvalidation'
require './modules/utilities'
require './modules/comparativesearch'
require './modules/dbinsert'
require 'date'
require 'sass'
require 'haml'
require './model'

Haml::Options.defaults[:format] = :xhtml

set :environment, :development
set :sessions, false
set :app_file, __FILE__
set :root, File.dirname(__FILE__)

library_columns = [:library_name, :carrier, :encoding_scheme, :insert_length]
selection_columns = [:selection_name___selection]
selection_all_columns = [:selection_name___selection, :library_name___library, :date, :performed_by,:species, :tissue, :cell]
dataset_columns = [:dataset_name ]
dataset_info_columns = [:dataset_name, :libraries__library_name, :selection_name, :sequencing_datasets__date, :species, :tissue, :cell, :selection_round, :carrier]
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
  @libraries = Library.select(*library_columns)
  haml :libraries
end

get '/libraries/:lib_name' do
  @libraries = Library.select(*library_columns)
  @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  haml :libraries
end

get '/show_sn_table' do
  if params['ref'] == "Library" 
    @column = :library_name
    @eletype = "Selections"
    @data = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  elsif params['ref'] == "Selection" 
    @column = :selection_name
    @eletype = "Sequencing Datasets"
    @data = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  elsif params['ref'] == "Sequencing Dataset" 
    @column = :sequencing_datasets__dataset_name
    @eletype = "Peptides"
    @data = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  end
  haml :show_sn_table, :layout => false
end

get '/show-info' do
  if params['ref'] == "Library"
    @info_data = Selection.join(Target, :target_id=>:target_id).select(*selection_all_columns)
    @eletype = "Selection"
    @next = "selections"
    @column = :selection_name
  elsif params['ref'] == "Selection"
    @info_data = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_all_columns)
    @eletype = "Sequencing Dataset"
    @next = "datasets"
    @column = :dataset_name
  elsif params['ref'] == "Sequencing Dataset"
    @info_data = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
    @peptide_dna = Peptide.join(DNAFinding, :peptide_sequence=>:peptide_sequence).join(SequencingDataset, :dataset_name =>:dataset_name).join(DNASequence, :dna_sequence=>:dna_sequences_peptides_sequencing_datasets__dna_sequence).select(*dna_columns)
    @eletype = "Peptide"
    @column1 = :peptides__peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
  end
  puts params['ele_name2'] 
  haml :show_info, :layout => false
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

get '/datasets' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns)
  haml :datasets
end

get '/datasets/:set_name' do
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :libraries__library_name => :sequencing_datasets__library_name).select(*dataset_info_columns)
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  haml :datasets
end

get '/clusters' do
  @clusters = Cluster
  haml :clusters
end

get '/clusters/:sel_cluster' do
  @clusters = Cluster
  @cluster_info = Cluster.select(:consensus_sequence, :dominance_sum, :reads_sum)
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

get '/systemic-search' do
  @libraries = Library.all
  @datasets = SequencingDataset.all
  @selections = Selection.all
  haml :sys_search
end

get '/systemic-search/:pep_seq' do
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

get '/property-search' do
  @libraries = Library
  @datasets = SequencingDataset
  @selections = Selection
  @targets = Target
  @results = Peptide.join(Observation, :peptide_sequence => :peptide_sequence).join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).join(Target, :selections__target_id___target => :targets__target_id___target)
  @querystring, @placeholders = build_property_array(params)
  haml :prop_search
end

get '/comparative-search' do
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

post '/comparative-results' do
  @ref_qry, @ref_placeh = build_rdom_string(params)
  @ds_qry, @ds_placeh = build_cdom_string(params)
  @peptides = comparative_search(params[:comp_type], params[:ref_ds], params[:radio_ds])
  
  haml :peptide_results, :layout => false
end

post '/systemic-results' do
  @peptides = Observation.select(:peptide_sequence,:dataset_name,:rank, :reads, :dominance).where(:dataset_name => params['sysDS'])
  haml :peptide_results, :layout => false
end

post '/peptide-infos' do
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :peptide_infos, :layout => false
end

get '/cluster-search' do
  @peptides = Peptide.select(:peptide_sequence)
  haml :cluster_search
end

post '/cluster-results' do
  @cluster = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).select(:clusters__cluster_id___id ,:consensus_sequence___consensus, :library_name___library, :selection_name___selection, :dataset_name___dataset )
  haml :peptide_results, :layout => false
end

post '/cluster-infos' do
  @cluster_infos = Cluster.where(:cluster_id => "#{params[:selCl]}")
  @cluster_peps = DB[:clusters_peptides].select(:peptide_sequence).where(:cluster_id => "#{params[:selCl]}")
  haml :cluster_infos, :layout => false
end

get '/motif-search' do
  @libraries = Library
  haml :motif_search
end

post '/motif-search' do
  @libraries = Library.all
  @datasets = SequencingDataset
  @selections = Selection
  haml :motif_search
end

get '/comparative-cluster-search' do
  @libraries = Library
  haml :comparative_cluster_search
end

get '/add-data' do
  haml :add_data
end

get '/addlibrary' do
  @schemes = Library.distinct.select(:encoding_scheme)
  @carriers = Library.distinct.select(:carrier)
  @producers = Library.distinct.select(:produced_by)
  haml :library_form, :layout => false
end
get '/addselection' do
  @libraries = Library.distinct.select(:library_name)
  @performs = Selection.distinct.select(:performed_by)
  @species = Target.distinct.select(:species)
  haml :selection_form, :layout => false
end
get '/adddataset' do
  @ds_infos = SequencingDataset.select(:read_type , :used_indices, :origin, :produced_by, :sequencer, :selection_round, :sequence_length)
  @libraries = Library
  @selections = Selection
  @species = Target.distinct.select(:species)
  haml :dataset_form, :layout => false
end
get '/addresult' do
  @datasets = SequencingDataset
  @species = Target.distinct.select(:species)
  @peptides
  haml :result_form, :layout => false
end
get '/addtarget' do
  @species = Target.distinct.select(:species)
  @tissues = Target.distinct.select(:tissue)
  @cells = Target.distinct.select(:cell)
  haml :target_form, :layout => false
end

get '/addcluster' do
  @libraries = Library
  @selection = Selection
  @datasets = SequencingDataset
  haml :cluster_form, :layout => false
end

get '/addmotif' do
  haml :motif_form, :layout => false
end

get '/formdrop' do
  @querystring, @placeholders = build_formdrop_string(params)
  req = !params[:required].nil? ? true : false
  @data = DB[params[:table].to_sym].distinct.select(params[:columnname].to_sym).where(Sequel.lit(@querystring, *@placeholders))
  haml :formdrop, :layout => false, locals:{values:@data, column:params[:columnname].to_sym, para:params['boxID'].to_sym, required:req }
end

get '/datalist' do
  @querystring, @placeholders = build_formdrop_string(params)
  val = !params[:required].nil? ? true : false
  @data = DB[params[:table].to_sym].distinct.select(params[:columnname].to_sym).where(Sequel.lit(@querystring, *@placeholders))
  haml :datalist, :layout => false, locals:{req: val,label: params[:label].to_s, fieldname: params[:fieldname].to_s,listname: params[:listname].to_s , listlabel:params[:listlabel].to_s, dbdata:@data, columnname:params[:columnname].to_sym  }
end

post '/validate-data' do
  @errors = validate(params)
  @values = params
  if @errors.empty?
    @dberrors = insert_data(@values)
    if @dberrors.empty?
      haml :insert_success, :layout => false
    else
      haml :validation_errors, :layout => false, locals:{errors: @dberrors}
    end
  else
    haml :validation_errors, :layout => false, locals:{errors: @errors}
  end
end

