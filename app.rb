# sinatra main configuration file
# loads all additional gems/modules, sets some options and 
# contains all routes served by this application
# pepdb.rb
require 'sinatra'
require 'sinatra/partial'
require 'sinatra/static_assets'
require './modules/querystringbuilder'
require './modules/formvalidation'
require './modules/utilities'
require './modules/comparativesearch'
require './modules/dbinsert'
require './modules/datatablesserver'
require './modules/motifsearch'
require './modules/compclustersearch'
require './modules/columnfinder'
require './modules/dbdelete'
require './modules/tooltips'
require './modules/aminoaciddist'
require 'digest/sha1'
require 'date'
require 'sass'
require 'haml'
require 'json'
require './model'
require 'sinatra-authentication'
require 'rack-flash'
require 'set'
require 'pdfkit'

Haml::Options.defaults[:format] = :xhtml

set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :public_folder, Proc.new {File.join(root, "public_html")}
set :default_encoding, "utf-8" 

use Rack::Session::Cookie, :expire_after => 3600, :secret => 'Gh6hh91uhMEsmq05h01ec2b4i9BRVj39' 
use Rack::Flash

configure do 
  mime_type :pdf, 'application/pdf'
end

# column to select in later database queries to create less clutter in the routes
library_columns = [:library_name___Name, :carrier___Carrier, :encoding_scheme___Encoding_scheme, :insert_length___Insert_length]
library_all = [:library_name, :encoding_scheme, :carrier, :produced_by, :date, :insert_length, :distinct_peptides, :peptide_diversity]
selection_columns = [:selection_name___Name, :species___Species, :tissue___Tissue, :cell___Cell]
selection_all_columns = [:selection_name___name, :selections__library_name___library, :selections__date, :carrier, :performed_by,:species, :tissue, :cell]
selection_info_columns = [:selection_name___name, :library_name___library, :date, :performed_by,:species, :tissue, :cell]
selection_edit_columns = [:selection_name, :library_name, :date, :performed_by,:targets__target_id___target]
dataset_columns = [:dataset_name___Name, :species___Species, :tissue___Tissue, :cell___Cell ]
dataset_info_columns = [:dataset_name___name, :libraries__library_name___library, :selection_name___selection, :sequencing_datasets__date, :species, :tissue, :cell, :selection_round, :carrier]
dataset_all_columns = [:dataset_name___name, :library_name___library, :selection_name___selection, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :species, :tissue, :cell, :statistic_file]
dataset_edit_columns = [:dataset_name, :library_name, :selection_name, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :targets__target_id___target, :statistic_file]
peptide_columns = [:peptide_sequence___Peptide_sequence, :rank___Rank, :reads___Reads , :dominance___Dominance]
sys_peptide_columns = [:peptides_sequencing_datasets__peptide_sequence___Peptide_sequence, :rank___Rank, :reads___Reads , :dominance___Dominance, :peptides_sequencing_datasets__dataset_name___Sequencing_dataset]
cluster_peptide_columns = [:clusters_peptides__peptide_sequence, :rank, :reads , :peptides_sequencing_datasets__dominance]
peptide_all_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name, :selection_name, :library_name, :rank, :reads, :dominance, :performance, :species, :tissue, :cell ]
clsearch_results = [:consensus_sequence___Consensus_sequence, :library_name___Library, :selection_name___Selection, :dataset_name___Sequencing_dataset]

# Order and naming for info columns shown in the browsing options
library_info = [:library_name___Name, :carrier___Carrier, :insert_length___Insert_length, :encoding_scheme___Encoding_scheme, :produced_by___Produced_by, :date___Date, :distinct_peptides___Distinct_peptides, :peptide_diversity___Peptide_diversity]
selection_info = [:selection_name___Name, :date___Date, :performed_by___Performed_by,:library_name___Library, :species___Species, :tissue___Tissue, :cell___Cell]
dataset_info = [:dataset_name___Name, :date___Date, :produced_by___Peformed_by, :statistic_file___Statistics, :library_name___Library, :selection_name___Selection, :selection_round___Selection_round, :species___Species, :tissue___Tissue, :cell___Cell, :origin___Origin, :sequencer___Sequencer, :read_type___Read_type, :sequence_length___Read_length, :used_indices___Used_barcode]
peptide_info = [:peptides_sequencing_datasets__peptide_sequence___Peptide, :sequencing_datasets__library_name___Library, :selection_name___Selection, :sequencing_datasets__dataset_name___Sequencing_dataset, :rank___Rank, :reads___Reads , :dominance___Dominance, :performance___Peptide_performance ]
dna_info = [:dna_sequences_peptides_sequencing_datasets__dna_sequence___DNA_sequence, :reads___Reads]
cluster_info = [:consensus_sequence___Consensus_sequence, :library_name___Library, :selection_name___Selection, :dataset_name___Sequencing_dataset, :dominance_sum___Dominance_sum, :parameters___Parameters]

# hashes containing the descriptions for add data forms
library_form = {
  :libname => {:label => "name", :type => "text", :required => true }, 
  :enc => {:label => "encoding scheme", :type => "datalist", :required => false, :col => :encoding_scheme, :db_data => nil}, 
  :ca => {:label => "carrier", :type => "datalist", :required => false, :col => :carrier, :db_data=> nil}, 
  :prod => {:label => "produced by", :type => "datalist", :required => false, :col => :produced_by, :db_data => nil}, 
  :insert => {:label => "insert length", :type => "text", :required => false}, 
  :diversity => {:label => "peptide diversity", :type => "text", :required => false}, 
  :date => {:label => "date", :type => "date"}} 

selection_form = {
  :selname => {:label => "name", :type => "text", :required => true }, 
  :date => {:label => "date", :type => "date"}, 
  :perf => {:label => "performed by", :type => "datalist", :required => false, :col => :performed_by, :db_data=> nil}, 
  :dtar => {:label => "target", :type => "target", :required => false}, 
  :dlibname => {:label => "related library", :type => "related", :required => true, :db_data => nil, :col => :library_name}} 

dataset_form = {
  :dsname => {:label => "name", :type => "text", :required => true }, 
  :date => {:label => "date", :type => "date"}, 
  :rt => {:label => "read type", :type => "datalist", :required => false, :col => :read_type, :db_data=> nil}, 
  :ui => {:label => "used barcode", :type => "datalist", :required => false, :col => :used_indices, :db_data=> nil}, 
  :or => {:label => "origin", :type => "datalist", :required => false, :col => :origin, :db_data=> nil}, 
  :prod => {:label => "produced by", :type => "datalist", :required => false, :col => :produced_by, :db_data=> nil}, 
  :seq => {:label => "sequencer", :type => "datalist", :required => false, :col => :sequencer, :db_data=> nil}, 
  :selr => {:label => "selection round", :type => "datalist", :required => false, :col => :selection_round, :db_data=> nil}, 
  :seql => {:label => "sequence length", :type => "datalist", :required => false, :col => :sequence_length, :db_data=> nil}, 
  :dtar => {:label => "target", :type => "target", :required => false}, 
  :dselname => {:label => "related selection", :type => "related", :required => true, :db_data => nil, :col => :selection_name}, 
  :pepfile => {:label => "peptide sequence file", :type => "file", :required => true }, 
  :statfile => {:label => "statistics file", :type => "file", :required => false } 
}

cluster_form = {
  :paras => {:label => "parameters", :type => "text", :required => false }, 
  :ddsname => {:label => "related sequencing dataset", :type => "related", :required => true, :db_data => nil, :col => :dataset_name}, 
  :clfile => {:label => "cluster file", :type => "file", :required => true } 
}

target_form = {
  :sp => {:label => "species", :type => "datalist", :required => false, :col => :species, :db_data=> nil}, 
  :tis => {:label => "tissue", :type => "datalist", :required => false, :col => :tissue, :db_data=> nil}, 
  :cell => {:label => "cell", :type => "datalist", :required => false, :col => :cell, :db_data=> nil}, 
}
performance_form = {
  :perf => {:label => "performance", :type => "area", :required => false }, 
  :dlibname => {:label => "related library", :type => "related", :required => true, :db_data => nil, :col => :library_name}, 
  :pseq => {:label => "peptide sequence", :type => "text", :required => true }, 
}

motif_form = {
  :mlname => {:label => "name", :type => "text", :required => true }, 
  :motfile => {:label => "motif list file", :type => "file", :required => true } 
}

# hashes containing the information necessary for the edit data forms
library_edit = {
  :libname => {:label => "name", :type => "id_field", :required => true, :col => :library_name }, 
  :enc => {:label => "encoding scheme", :type => "editlist", :required => false, :col => :encoding_scheme, :db_data => nil}, 
  :ca => {:label => "carrier", :type => "editlist", :required => false, :col => :carrier, :db_data=> nil}, 
  :prod => {:label => "produced by", :type => "editlist", :required => false, :col => :produced_by, :db_data => nil}, 
  :insert => {:label => "insert length", :type => "text", :required => false, :col => :insert_length}, 
  :diversity => {:label => "peptide diversity", :type => "text", :required => false, :col => :peptide_diversity}, 
  :date => {:label => "date", :type => "date", :col => :date} 
}

selection_edit = {
  :selname => {:label => "name", :type => "id_field", :required => true, :col => :selection_name }, 
  :date => {:label => "date", :type => "date", :col => :date}, 
  :perf => {:label => "performed by", :type => "datalist", :required => false, :col => :performed_by, :db_data=> nil}, 
  :dtar => {:label => "target", :type => "target", :required => false, :col => :target}, 
  :dlibname => {:label => "related library", :type => "related", :required => true, :db_data => nil, :col => :library_name}
}

dataset_edit = {
  :dsname => {:label => "name", :type => "id_field", :required => true, :col => :dataset_name }, 
  :date => {:label => "date", :type => "date", :col => :date}, 
  :rt => {:label => "read type", :type => "editlist", :required => false, :col => :read_type, :db_data=> nil}, 
  :ui => {:label => "used barcode", :type => "editlist", :required => false, :col => :used_indices, :db_data=> nil}, 
  :or => {:label => "origin", :type => "editlist", :required => false, :col => :origin, :db_data=> nil}, 
  :prod => {:label => "produced by", :type => "editlist", :required => false, :col => :produced_by, :db_data=> nil}, 
  :seq => {:label => "sequencer", :type => "editlist", :required => false, :col => :sequencer, :db_data=> nil}, 
  :selr => {:label => "selection round", :type => "editlist", :required => false, :col => :selection_round, :db_data=> nil}, 
  :seql => {:label => "sequence length", :type => "editlist", :required => false, :col => :sequence_length, :db_data=> nil}, 
  :dtar => {:label => "target", :type => "target", :required => false, :col => :target}, 
  :dselname => {:label => "related selection", :type => "related", :required => true, :db_data => nil, :col => :selection_name}, 
  :statfile => {:label => "statistics file", :type => "statfile", :required => false, :col => :statistic_file, :path => "statpath" } 
}

target_edit = {
  :sp => {:label => "species", :type => "editlist", :required => false, :col => :species, :db_data=> nil}, 
  :tis => {:label => "tissue", :type => "editlist", :required => false, :col => :tissue, :db_data=> nil}, 
  :cell => {:label => "cell", :type => "editlist", :required => false, :col => :cell, :db_data=> nil}, 
}

performance_edit = {
  :perf => {:label => "performance", :type => "area", :required => false, :col => :performance }, 
  :dlibname => {:label => "related library", :type => "related", :required => true, :db_data => nil, :col => :library_name}, 
  :pseq => {:label => "peptide sequence", :type => "id_field", :required => true , :col => :peptide_sequence} 
}

cluster_edit = {
  :paras => {:label => "parameters", :type => "text", :required => false, :col => :parameters }, 
  :ddsname => {:label => "related sequencing dataset", :type => "related", :required => true, :db_data => nil, :col => :dataset_name}, 
  :peptides => {:type => "peptides"}
}

motif_edit = {
  :mlname => {:label => "name", :type => "id_field", :required => true, :col => :list_name },
  :motifs => {:type => "motifs"}
}

get '/' do
  login_required
  haml :main
end

get '/*style.css' do
  scss :style
end

########## Data Browsing #############
get '/libraries' do
  login_required
  if current_user.admin?
    @libraries = Library.select(*library_columns)
  else
    allowed = get_accessible_elements(:libraries)
    @libraries = DB[:libraries].select(*library_columns).where(:library_name => allowed)
  end
  if @libraries.empty?
    @message = "No libraries found in database"
    haml :empty
  else
    haml :libraries
  end
end

get '/libraries/:lib_name' do
  login_required
  if current_user.admin?
    @libraries = Library.select(*library_columns)
    @selections = Selection.left_join(Target, :target_id=>:target_id).select(*selection_columns)
  elsif can_access?(:libraries, params[:lib_name])
    allowed = get_accessible_elements(:libraries)
    @libraries = DB[:libraries].select(*library_columns).where(:library_name => allowed)
    allowed_sel = get_accessible_elements(:selections)
    @selections = Selection.left_join(Target, :target_id=>:target_id).select(*selection_columns).where(:Name => allowed_sel)
  else
    redirect '/libraries'
  end
  @infodata = Library.select(*library_info)
  haml :libraries
end

get '/selections' do
  login_required
  if current_user.admin?
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_columns)
  else
    allowed = get_accessible_elements(:selections)
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_columns).where(:selection_name => allowed)
  end
  if @selections.empty?
    @message = "No selections found in database"
    haml :empty
  else
    haml :selections
  end
end

get '/selections/:sel_name' do
  login_required
  if current_user.admin?
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_columns)
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_columns)
  elsif can_access?(:selections, params[:sel_name])
    allowed = get_accessible_elements(:selections)
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_columns).where(:selection_name => allowed)
    allowed_ds = get_accessible_elements(:sequencing_datasets)
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_columns).where(:Name => allowed_ds)
  else
    redirect '/selections'
  end
  @infodata = Selection.select(*selection_info).left_join(Target, :target_id => :target_id).where(:selection_name => params[:sel_name])
  @eletype = "Selection"
  haml :selections
end

get '/datasets' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_columns)
  else
    allowed = get_accessible_elements(:sequencing_datasets) 
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_columns).where(:dataset_name => allowed)
  end
  if @datasets.empty?
    @message = "No sequencing datasets found in database"
    haml :empty
  else
    haml :datasets
  end
end

get '/datasets/:set_name' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :libraries__library_name => :sequencing_datasets__library_name).select(*dataset_columns)
  elsif can_access?(:sequencing_datasets, params[:set_name])
    allowed = get_accessible_elements(:sequencing_datasets) 
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_columns).where(:dataset_name => allowed)
  else
    redirect '/datasets'
  end
  @peptides = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  @infodata = SequencingDataset.select(*dataset_info).left_join(Target, :target_id => :target_id).where(:dataset_name => params[:set_name])
  @pep_count = Observation.where(:dataset_name => params[:ele_name].to_s).sum(:reads)
  @eletype = "Sequencing Dataset"
  haml :datasets
end

get '/clusters' do
  login_required
  unless current_user.admin?
    @datasets = get_accessible_elements(:sequencing_datsets) 
    @clusters = Cluster.where(:dataset_name => @datasets)
  else
    @clusters = Cluster
  end
  haml :clusters
end

get '/clusters/:sel_cluster' do
  login_required
  ds = Cluster.select(:dataset_name).where(:cluster_id => params[:sel_cluster].to_i).first 
  if current_user.admin?  
    @clusters = Cluster
  elsif can_access?(:sequencing_datasets, ds[:dataset_name])
    @datasets = get_accessible_elements(:sequencing_datsets) 
    @clusters = Cluster.where(:dataset_name => @datasets)
  else
    redirect "/clusters"
  end
    @cluster_info = Cluster.select(:consensus_sequence, :dominance_sum, :reads_sum)
    @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  haml :clusters
end

get '/clusters/:sel_cluster/:pep_seq' do
  login_required
  ds = Cluster.select(:dataset_name).where(:cluster_id => params[:sel_cluster].to_i).first 
  if current_user.admin?  
    @clusters = Cluster
  elsif can_access?(:sequencing_datasets, ds[:dataset_name])
    @datasets = get_accessible_elements(:sequencing_datsets) 
    @clusters = Cluster.where(:dataset_name => @datasets)
  else
    redirect "/clusters"
  end
  @cluster_info = Cluster.select(:consensus_sequence, :dominance_sum, :parameters)
  @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :clusters
end

####### Data Browsing Helper Routes ####################
get '/cluster-infos' do
  login_required
  if request.referrer.include?("comparative-cluster")
    qry, placeholder = build_comp_cl_string(params)
    @cluster_infos = Cluster.select(*cluster_info).where(Sequel.lit(qry,*placeholder)).all
    @reads_sum, @cluster_peps = calc_cluster_read_sums(params)
  elsif request.referrer.include?("cluster-search")
    @cluster_infos = Cluster.where(:consensus_sequence => params[:selCl].to_s,:dataset_name => params[:selDS].to_s).select(*cluster_info).all
    @cluster_peps = DB[:clusters_peptides].join(:clusters, :cluster_id=>:cluster_id).select(:peptide_sequence___Peptide_sequence).where(:consensus_sequence => params[:selCl].to_s, :dataset_name => params[:selDS].to_s).all
    @reads_sum = Observation.where(:dataset_name => @cluster_infos[0][:Sequencing_dataset], :peptide_sequence => @cluster_peps.map{|pep| pep[:Peptide_sequence]}).sum(:reads)
  else
    @cluster_infos = Cluster.where(:cluster_id => "#{params[:selCl]}").select(*cluster_info).all
    @cluster_peps = DB[:clusters_peptides].select(:peptide_sequence___Peptide_sequence).where(:cluster_id => "#{params[:selCl]}").all
    @reads_sum = Observation.where(:dataset_name => @cluster_infos[0][:Sequencing_dataset], :peptide_sequence => @cluster_peps.map{|pep| pep[:Peptide_sequence]}).sum(:reads)
  end
  haml :cluster_infos, :layout => false
end

get '/show_sn_table' do
  login_required
  if params['ref'] == "Library" 
    @column = :library_name
    @eletype = "Selections"
    @id = :show_table
    allowed_sel = get_accessible_elements(:selections)
    @data = Selection.left_join(Target, :target_id=>:target_id).select(*selection_columns).where(:Name => allowed_sel)
  elsif params['ref'] == "Selection" 
    @column = :selection_name
    @eletype = "Sequencing Datasets"
    @id = :show_table
    allowed_ds = get_accessible_elements(:sequencing_datasets)
    @data = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_columns).where(:Name => allowed_ds)
  elsif params['ref'] == "Sequencing Dataset" 
    @column = :sequencing_datasets__dataset_name
    @eletype = "Peptides"
    @id = :pep_table
    @data = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  end
  haml :show_sn_table, :layout => false
end

get '/info-tables' do
  login_required
  if request.referer.include?("libraries")
    @infodata = Library.select(*library_info).where(:library_name => params[:infoElem])
  elsif request.referer.include?("selection")
    @infodata = Selection.select(*selection_info).left_join(Target, :target_id => :target_id).where(:selection_name => params[:infoElem])
    @eletype = "Selection"
  elsif request.referer.include?("datasets")
    @infodata = SequencingDataset.select(*dataset_info).left_join(Target, :target_id => :target_id).where(:dataset_name => params[:infoElem])
    @pep_count = Observation.where(:dataset_name => params[:infoElem].to_s).sum(:reads)
    @eletype = "Sequencing Dataset" 
  end
  haml :info_tables, :layout => false, locals:{data_to_display:@infodata, element:"#{h params[:infoElem]}", pep_count:@pep_count, type:@eletype}
end

get '/show-info' do
  login_required
  if params['ref'] == "Library"
    @eletype = "Selection"
    @next = "selections"
    @column = :selection_name
    @element = params[:ele_name].to_s
    @info_data = Selection.left_join(Target, :target_id=>:target_id).select(*selection_info).where(:selection_name => @element).all
    haml :show_info, :layout => false
  elsif params['ref'] == "Selection"
    @pep_count = Observation.where(:dataset_name => params[:ele_name].to_s).sum(:reads)
    @eletype = "Sequencing Dataset"
    @next = "datasets"
    @column = :dataset_name
    @element = params[:ele_name].to_s
    @info_data = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_info).where(:dataset_name => @element).all
    haml :show_info, :layout => false
  elsif params['ref'] == "Sequencing Dataset"
    @element = params[:ele_name].to_s
    corres_dataset = params[:ele_name2].to_s
    @info_data = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).left_join(PeptidePerformance, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence___peptide, :sequencing_datasets__library_name => :peptide_performances__library_name).select(*peptide_info).where(:Peptide => @element, :Sequencing_dataset => corres_dataset).all
    @peptide_dna = DnaFinding.join(SequencingDataset, :dataset_name =>:dataset_name).select(*dna_info).where(:peptide_sequence => params[:ele_name], :sequencing_datasets__dataset_name => params[:ele_name2]).to_hash(:DNA_sequence, :Reads)
    @eletype = "Peptide"
    @column1 = :Peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
    haml :show_info, :layout => false
  elsif (params[:ref] == "Clusters" || params[:ref] == "Clustersearch")
    dataset = Cluster.select(:dataset_name).where(:cluster_id => params[:ele_name2].to_i).first if params[:ref] == "Clusters"
    dataset = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).select(:dataset_name).where(:peptide_sequence => params[:ele_name].to_s, :consensus_sequence => params[:ele_name2].to_s).first if params[:ref] == "Clustersearch"
    corres_dataset = dataset[:dataset_name]
    @eletype = "Peptide"
    @column1 = :peptides__peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
    @info_data = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).left_join(PeptidePerformance, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence___peptide, :sequencing_datasets__library_name => :peptide_performances__library_name).select(*peptide_info).where(:Peptide => params[:ele_name].to_s, :Sequencing_dataset => corres_dataset).all
    @peptide_dna = DnaFinding.join(SequencingDataset, :dataset_name => :dataset_name).select(*dna_info).where(:sequencing_datasets__dataset_name => corres_dataset, :peptide_sequence => params[:ele_name].to_s).to_hash(:DNA_sequence, :Reads)
    @element = params[:ele_name].to_s
    haml :show_info, :layout => false
  elsif params['ref'] == "comparative"
    @datasets = params['selRow'].to_set
    @info_data = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).left_join(PeptidePerformance, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence___peptide, :sequencing_datasets__library_name => :peptide_performances__library_name).select(*peptide_info).where(:Peptide => params[:ele_name].to_s, :Sequencing_dataset => corres_dataset).all
    @peptide_dna = Peptide.join(DnaFinding, :peptide_sequence=>:peptide_sequence).join(SequencingDataset, :dataset_name =>:dataset_name).join(DnaSequence, :dna_sequence=>:dna_sequences_peptides_sequencing_datasets__dna_sequence).select(*dna_info)
    @eletype = "Peptide"
    @column1 = :peptides__peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
    @element = params[:ele_name].to_s
    if params[:comptype] == "ref_and_ds"
      haml :ref_ds_comp, :layout => false
    else
      haml :show_info, :layout => false
    end
  end
end

######## Peptide Search #################
#------- Systemic Search -------------#
get '/systemic-search' do
  login_required
  if current_user.admin?
    @libraries = Library.all
    @selections = Selection.all
    @datasets = SequencingDataset.all
  else
    allowed_lib = get_accessible_elements(:libraries) 
    allowed_sel = get_accessible_elements(:selections) 
    allowed_ds = get_accessible_elements(:sequencing_datasets) 
    @libraries = Library.where(:library_name =>allowed_lib).all
    @selections = Selection.where(:selection_name => allowed_sel).all
    @datasets = SequencingDataset.where(:dataset_name => allowed_ds).all
  end
  haml :sys_search
end

get '/systemic-results' do
  login_required
  if params['sysDS'].nil?
     
    @errors = {:ds =>"No sequencing datasets selected."}
    haml :validation_errors_wo_header, :layout => false, locals:{errors:@errors}
  else
    @peptides = Observation.select(*sys_peptide_columns).where(:Sequencing_dataset => params['sysDS'])
    haml :peptide_results, :layout => false
  end
end

#------- Property Search -------------#
get '/property-search' do
  login_required
  if current_user.admin?
    @libraries = Library
    @datasets = SequencingDataset
    @selections = Selection
  else
    allowed_lib = get_accessible_elements(:libraries) 
    allowed_sel = get_accessible_elements(:selections) 
    allowed_ds = get_accessible_elements(:sequencing_datasets) 
    @libraries = Library.where(:library_name =>allowed_lib).all
    @selections = Selection.where(:selection_name => allowed_sel).all
    @datasets = SequencingDataset.where(:dataset_name => allowed_ds).all
  end
  @targets = Target
  haml :prop_search
end

get '/property-results' do
  login_required
  @results = Observation.join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(PeptidePerformance, :sequencing_datasets__library_name => :peptide_performances__library_name, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence).left_join(:targets___sel_target, :selections__target_id => :sel_target__target_id).left_join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).select(*sys_peptide_columns)
  begin
    @querystring, @placeholders = build_property_array(params)
    if option_selected?(params[:blos])
      raise ArgumentError, "similarity quotient must be between 0 and 1" if (params[:sq].to_f < 0 || params[:sq].to_f > 1)
      raise ArgumentError, "query sequence must only contain characters a-z" if params[:seq].to_s.match(/[^a-zA-Z]/)
      @sim_quots = find_neighbours(params[:seq].to_s.upcase, params[:blos].to_i, params[:sq].to_f,@querystring, @placeholders)
    end
    DB.create_table?(:propqry, :temp => true) do
      primary_key :qry_id
      Text :qry_string
      Text :placeholder
      index :qry_id
    end
    @qry_id = DB[:propqry].insert(:qry_string => @querystring.to_s, :placeholder => @placeholders.join(","))
  rescue ArgumentError => e
    @error = e.message
  end
  puts "sadfffffffffffffffffff"
  puts @querystring
  puts @placeholders.inspect
  haml :prop_results, :layout => false
end


#--------- Comparative Peptide Search --------------#

get '/comparative-search' do
  login_required
  if current_user.admin?
    @libraries = Library.all
    @datasets = SequencingDataset
    @selections = Selection
  else
    allowed_lib = get_accessible_elements(:libraries) 
    allowed_sel = get_accessible_elements(:selections) 
    allowed_ds = get_accessible_elements(:sequencing_datasets) 
    @libraries = Library.where(:library_name =>allowed_lib).all
    @selections = Selection.where(:selection_name => allowed_sel).all
    @datasets = SequencingDataset.where(:dataset_name => allowed_ds).all
  end
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*sys_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :comp_search

end

get '/comparative-results' do
  login_required
  @errors = {}
  if params[:radio_ds].nil? || params[:ref_ds].nil?
    @errors[:ds] = "at least one dataset selection per section needed!"
  elsif (params[:ref_dom_max].empty? && params[:ref_dom_min].empty?) || (params[:ds_dom_max].empty? && params[:ds_dom_min].empty?)
    @errors[:dom] = "at least one dominance limit needs to be selected per section!"
  end
  if @errors.empty?
    @datasets = [params[:radio_ds], *params[:ref_ds]].to_set
    @maxlength = params[:ref_ds].size
    @ref_qry, @ref_placeh = build_rdom_string(params)
    @ds_qry, @ds_placeh = build_cdom_string(params)
    @uniq_peptides, @common_peptides = comparative_search(params[:comp_type], params[:ref_ds], params[:radio_ds])
    peptides = @common_peptides.map(:peptide_sequence).concat(@uniq_peptides.map(:peptide_sequence))
    @first_ds = Observation.select(:dataset_name, :peptide_sequence, :dominance).where(:dataset_name => params[:radio_ds], :peptide_sequence => peptides).to_hash_groups(:peptide_sequence, :dominance)
    @results = Peptide.select(:peptide_sequence).where(:peptide_sequence => @common_peptides.map(:peptide_sequence)).all
    @specs = DB[:peptides_sequencing_datasets].select(:peptide_sequence, :dominance).where(:peptide_sequence => @common_peptides.map(:peptide_sequence), :dataset_name => params[:ref_ds]).to_hash_groups(:peptide_sequence, :dominance)
    haml :peptide_results, :layout => false
  else
    haml :validation_errors_wo_header, :layout => false, locals:{errors:@errors}
  end
end


# -------- Motif Search ----------- #

get '/motif-search' do
  login_required
  if current_user.admin?
    @libraries = Library
  else
    allowed = get_accessible_elements(:libraries) 
    @libraries = Library.where(:library_name => allowed)
  end
  @motiflists = MotifList
  haml :motif_search
end

get '/mot-checklist' do
  login_required
  if params[:checkedElem].nil?
    haml :empty, :layout => false
  else
    @motlists = DB[:motifs_motif_lists].distinct.select(:motif_sequence, :target, :receptor, :source).where(:list_name => params[:checkedElem])
    haml :mot_checklist, :layout => false
  end
end

get '/motif-search-results' do
  login_required
  @errors = {}
  if params[:ref_ds].nil?
    @errors[:dataset] = "no dataset selected!" 
  elsif params[:checked_motl].nil?
    @errors[:motl] = "no motif list selected!" 
  elsif params[:ds_dom_max].empty? && params[:ds_dom_min].empty?
    @errors[:dom] = "at least one dominance limit needs to be selected!"
  end
  if @errors.empty?
    DB.create_table!(:mot_matches, :temp => true) do
      String :motif_sequence
      String :dataset_name
      String :peptide_sequence
      Float :dominance
      primary_key [:motif_sequence, :peptide_sequence, :dataset_name]
      index [:motif_sequence, :peptide_sequence, :dataset_name]
    end
    @table = :mot_matches
    @datasets = params[:ref_ds]
    @ds_qry, @ds_placeh = build_cdom_string(params)
    @peptides = Observation.distinct.select(:peptide_sequence).where(:dataset_name => @datasets).where(Sequel.lit(@ds_qry, *@ds_placeh)).all
    @motlists = DB[:motifs_motif_lists].distinct.select(:motif_sequence).where(:list_name => params[:checked_motl])
   
    search_peptide_motif_matches(@motlists, @peptides, @datasets, @table)
    @pep_per_mots = DB[@table].select(:motif_sequence, :peptide_sequence).to_hash_groups(:motif_sequence, :peptide_sequence)
    @uniq_pep_per_mots = DB[@table].distinct.select(:motif_sequence, :peptide_sequence).to_hash_groups(:motif_sequence, :peptide_sequence)
    @ds_per_peps = DB[@table].distinct.select(:peptide_sequence, :dataset_name).to_hash_groups(:peptide_sequence, :dataset_name)
    @dom_per_peps = DB[@table].distinct.select(:peptide_sequence, :dataset_name, :dominance).to_hash_groups(:peptide_sequence)
    @mot_infos = DB[:motifs_motif_lists].select(:motif_sequence, :target, :receptor).where(:list_name => params[:checked_motl]).to_hash(:motif_sequence)
    haml :mot_search_res, :layout => false
  else
    haml :validation_errors_wo_header, :layout => false, locals:{errors:@errors}
  end
end

#----------- Peptide Search Helper Routes -----------#
get '/peptide-infos' do
  login_required
  @element = params['selSeq'].to_s
  @eletype = "Peptide"
  
  if request.referrer.include?('comparative-search')
    puts request.referrer
    puts params[:refDS].inspect
    @eletype = "Peptide Comparative"
    @peptides_info = []
    @peptides_dna = []
    ref_ds = params[:refDS].to_a.map{|ds| ds.to_s }
    @peptides_dna = DnaFinding.select(:dataset_name, *dna_info).where(:dataset_name => ref_ds, :peptide_sequence => @element).to_hash_groups(:dataset_name)
    @peptides_info = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).left_join(PeptidePerformance, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence___peptide, :sequencing_datasets__library_name => :peptide_performances__library_name).select(*peptide_info).where(:Peptide => @element, :Sequencing_dataset => ref_ds).all

  else
    corres_dataset = params['selDS'].to_s
    @info_data = Observation.join(SequencingDataset, :dataset_name___dataset=>:dataset_name).left_join(PeptidePerformance, :peptides_sequencing_datasets__peptide_sequence => :peptide_performances__peptide_sequence___peptide, :sequencing_datasets__library_name => :peptide_performances__library_name).select(*peptide_info).where(:Peptide => @element, :Sequencing_dataset => corres_dataset).all
    @peptide_dna = DnaFinding.join(SequencingDataset, :dataset_name => :dataset_name).select(*dna_info).where(:sequencing_datasets__dataset_name => corres_dataset, :peptide_sequence => @element).to_hash(:DNA_sequence, :Reads)
  end

  haml :show_info, :layout => false
end

post '/checklist' do
  login_required
  puts params.inspect
  puts "sdfasdfipasdfopiuhhhhhhhhhhhhhhhhh"
  puts params[:checkedElem].inspect
  case params[:selector]
  when "sel"
    table = :libraries
  when "ds"
    table = :selections
  end
  if params[:checkedElem].nil?
  elsif (current_user.admin? || can_access?(table, params[:checkedElem]))
    @data_to_display, @column = choose_data(params)
    @section = params['sec']
    haml :checklist, :layout => false
  else
    redirect '/empty'
  end
end

post '/radiolist' do
  login_required
  if params[:checkedElem].nil?
  elsif current_user.admin? || can_access?(:selections, params[:checkedElem])
    @data_to_display = SequencingDataset.select(:dataset_name).where(:selection_name => params['checkedElem'])
  else
    redirect '/empty'
  end
  @column = :dataset_name
  haml :radiolist, :layout => false
end
######## Cluster Search ###############
#----------- Sequence Search ----------#
get '/cluster-search' do
  login_required
  @peptides = Peptide.select(:peptide_sequence)
  haml :cluster_search
end

get '/cluster-results' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.select(:dataset_name).map(:dataset_name)
  else
    allowed = get_accessible_elements(:sequencing_datasets) 
    @datasets = SequencingDataset.select(:dataset_name).where(:dataset_name => allowed).map(:dataset_name)
  end
  @cluster = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).select(*clsearch_results)
  haml :peptide_results, :layout => false
end

#------- Comparative Cluster Search ------------#
get '/comparative-cluster-search' do
  login_required
  if current_user.admin?
    @libraries = Library
  else
    allowed = get_accessible_elements(:libraries)
    @libraries = Library.where(:library_name => allowed)
  end
  haml :comparative_cluster_search
end

get '/comparative-cluster-results' do
  login_required
  @errors = {}
  if params[:ref_ds].nil? || params[:radio_ds].nil?
    @errors[:ds] = "select two or more datasets!"
  elsif (!option_selected?(params[:ref_dom_min])|| !option_selected?(params[:ds_dom_min])) 
    @errors[:type] = "dominance values missing" 
  elsif !option_selected?(params[:simsc])
    @errors[:type] = "similarity score missing" 
  end

  if @errors.empty?
    @columns = Cluster.select(:consensus_sequence, :dominance_sum___dominance).first
    @datasets = params[:ref_ds]
    @matches, @scores, @cluster_to_matches = comp_cluster_search(params[:radio_ds], params[:ref_ds], params[:simsc], params[:ds_dom_min], params[:ref_dom_min])
    @investigated_cl = Cluster.select(:consensus_sequence, :dominance_sum, :dataset_name).where(:dataset_name => params[:radio_ds]).where("dominance_sum > ?", params[:ds_dom_min].to_f).all
    #@match_cl = Cluster.select(:consensus_sequence, :dominance_sum, :dataset_name).where(Sequel.like(:consensus_sequence, *@matches), :dataset_name => params[:ref_ds].to_a.map{|s| s.to_s}).to_hash_groups(:consensus_sequence)
    @match_cl = Cluster.select(:consensus_sequence, :dominance_sum, :dataset_name).where(:consensus_sequence => @matches, :dataset_name => params[:ref_ds].to_a.map{|s| s.to_s}).to_hash_groups(:consensus_sequence)
    @max_length = get_max_row_length(@cluster_to_matches, @match_cl)
    @clusters = Cluster.select(:dataset_name, :dominance_sum)
    @tab_rows, @header, @is_numeric_cell = format_comp_cl_data(@investigated_cl, @cluster_to_matches, @match_cl,@scores, @max_length)
    haml :comparative_cluster_results, :layout => false
  else
    haml :validation_errors_wo_header, :layout => false, locals:{errors:@errors}
  end
end

####### Cluster Helper Routes #########
=begin
get '/cluster-info' do
  if request.referrer.include?("comparative-cluster")
  else
    dataset = Cluster.select(:dataset_name).where(:cluster_id => params[:ele_name2].to_i).first
    corres_dataset = dataset[:dataset_name]
    @eletype = "Peptide"
    @column1 = :peptides__peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
    @info_data = Observation.join(SequencingDataset, :dataset_name___dataset=> :dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :results__target_id => :targets__target_id).select(*peptide_info).where(:Sequencing_dataset => corres_dataset, :peptide_sequence => params[:ele_name].to_s)
    @peptide_dna = DnaFinding.join(SequencingDataset, :dataset_name => :dataset_name).select(*dna_info).where(:sequencing_datasets__dataset_name => corres_dataset, :peptide_sequence => params[:ele_name].to_s).to_hash(:DNA_sequence, :Reads)
    @element = params[:ele_name].to_s
  end
  haml :show_info, :layout => false
end
=end


############ Add Data ################

get '/add-data' do
  login_required
  redirect "/" unless current_user.admin?
  haml :add_data
end

get '/addlibrary' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = library_form
  @form_fields[:enc][:db_data] = Library.distinct.select(:encoding_scheme).all
  @form_fields[:ca][:db_data] = Library.distinct.select(:carrier).all
  @form_fields[:prod][:db_data] =  Library.distinct.select(:produced_by).all
  @form_type = "library"
  
  #haml :library_form, :layout => false
  haml :add_data_form, :layout => false
end
get '/addselection' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = selection_form
  @form_fields[:dlibname][:db_data] = Library.distinct.select(:library_name).all
  @form_fields[:perf][:db_data] = Selection.distinct.select(:performed_by).all
  @form_type = "selection"
  haml :add_data_form, :layout => false
end
get '/adddataset' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = dataset_form
  @form_fields[:rt][:db_data] = SequencingDataset.distinct.select(:read_type).all
  @form_fields[:ui][:db_data] = SequencingDataset.distinct.select(:used_indices).all
  @form_fields[:or][:db_data] = SequencingDataset.distinct.select(:origin).all
  @form_fields[:prod][:db_data] = SequencingDataset.distinct.select(:produced_by).all
  @form_fields[:seq][:db_data] = SequencingDataset.distinct.select(:sequencer).all
  @form_fields[:selr][:db_data] = SequencingDataset.distinct.select(:selection_round).all
  @form_fields[:seql][:db_data] = SequencingDataset.distinct.select(:sequence_length).all
  @form_fields[:dselname][:db_data] = Selection.distinct.select(:selection_name).all
  @form_type = "dataset"
  haml :add_data_form, :layout => false
end
get '/addperformance' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = performance_form
  @form_fields[:dlibname][:db_data] = Library.distinct.select(:library_name).all
  @form_type = "performance"
  haml :add_data_form, :layout => false
end
get '/addtarget' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = target_form
  @form_fields[:sp][:db_data] = Target.distinct.select(:species).all
  @form_fields[:tis][:db_data] = Target.distinct.select(:tissue).all
  @form_fields[:cell][:db_data] = Target.distinct.select(:cell).all
  @form_type = "target"
  haml :add_data_form, :layout => false
end

get '/addcluster' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = cluster_form
  @form_fields[:ddsname][:db_data] = SequencingDataset.distinct.select(:dataset_name).all
  @form_type = "cluster"
  haml :add_data_form, :layout => false
end

get '/addmotif' do
  login_required
  redirect "/" unless current_user.admin?
  @form_fields = motif_form
  @form_type = "motif list"
  haml :add_data_form, :layout => false
end

######### Edit Data ##################
get '/edit-data' do
  login_required
  redirect "/" unless current_user.admin?
  haml :edit_data
end

get '/editlibraries' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_type = "library"
    @form_table = :libraries
    @form_fields = library_edit
    @form_fields[:enc][:db_data] =  Library.distinct.select(:encoding_scheme).all
    @form_fields[:ca][:db_data] = Library.distinct.select(:carrier).all
    @form_fields[:prod][:db_data] =  Library.distinct.select(:produced_by).all
    @values = Library.select(*library_all).where(:library_name => params[:selElem].to_s).first 
    haml :edit_data_form, :layout => false
  end
end

get '/editselections' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_fields = selection_edit
    @form_fields[:dlibname][:db_data] = Library.distinct.select(:library_name).all
    @form_fields[:perf][:db_data] = Selection.distinct.select(:performed_by).all
    @form_type = "selection"
    @values = Selection.select(*selection_edit_columns).left_join(Target, :target_id => :target_id).where(:selection_name => params[:selElem].to_s).first
    @form_table = :selections
    haml :edit_data_form, :layout => false
  end
end

get '/editsequencing-datasets' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_fields = dataset_edit
    @form_fields[:rt][:db_data] = SequencingDataset.distinct.select(:read_type).all
    @form_fields[:ui][:db_data] = SequencingDataset.distinct.select(:used_indices).all
    @form_fields[:or][:db_data] = SequencingDataset.distinct.select(:origin).all
    @form_fields[:prod][:db_data] = SequencingDataset.distinct.select(:produced_by).all
    @form_fields[:seq][:db_data] = SequencingDataset.distinct.select(:sequencer).all
    @form_fields[:selr][:db_data] = SequencingDataset.distinct.select(:selection_round).all
    @form_fields[:seql][:db_data] = SequencingDataset.distinct.select(:sequence_length).all
    @form_fields[:dselname][:db_data] = Selection.distinct.select(:selection_name).all
    @form_type = "dataset"
    @values = SequencingDataset.select(*dataset_edit_columns).left_join(Target, :target_id => :target_id).where(:dataset_name => params[:selElem].to_s).first
    @form_table = :sequencing_datasets
    haml :edit_data_form, :layout => false
  end
end

get '/edittargets' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_fields = target_edit
    @form_fields[:sp][:db_data] = Target.distinct.select(:species).all
    @form_fields[:tis][:db_data] = Target.distinct.select(:tissue).all
    @form_fields[:cell][:db_data] = Target.distinct.select(:cell).all
    @form_type = "target"
    @values = Target.select(:species, :tissue, :cell).where(:target_id => params[:selElem].to_i).first
    @form_table = :targets
    haml :edit_data_form, :layout => false
  end
end
get '/editperformances' do
  login_required
  redirect "/" unless current_user.admin?
  if (params[:selElem].match(/^[[:space:]]$/) || params[:selLib].match(/^[[:space:]]$/) )
    haml :empty, :layout => false
  else
    @form_fields = performance_edit
    @form_fields[:dlibname][:db_data] = Library.distinct.select(:library_name).all
    @form_type = "performance"
    @form_table = :peptide_performances
    @values = PeptidePerformance.select(:performance, :library_name, :peptide_sequence).where(:library_name => params[:selLib].to_s, :peptide_sequence => params[:selElem].to_s).first
    haml :edit_data_form, :layout => false
  end
end

get '/editmotif-lists' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_fields = motif_edit
    @form_type = "motif list"
    @form_table = :motif_lists
    @values = DB[:motif_lists].select(:list_name).where(:list_name => params[:selElem].to_s).first
    @motlist = DB[:motifs_motif_lists].select(:motif_sequence, :target, :receptor, :source).where(:list_name => params[:selElem].to_s)
    haml :edit_data_form, :layout => false
  end
end

get '/editclusters' do
  login_required
  redirect "/" unless current_user.admin?
  if params[:selElem].match(/^[[:space:]]$/) 
    haml :empty, :layout => false
  else
    @form_fields = cluster_edit
    @form_fields[:ddsname][:db_data] = SequencingDataset.distinct.select(:dataset_name).all
    @form_type = "cluster"
    @form_table = :clusters
    @values = Cluster.select(:parameters, :dataset_name, :cluster_id).where(:cluster_id => params[:selElem]).first
    @peptides = DB[:clusters_peptides].select(:peptide_sequence).where(:cluster_id => params[:selElem]).all
    haml :edit_data_form, :layout => false
  end
end

delete '/delete-entry' do
  login_required
  redirect "/" unless current_user.admin?
  delete_entry(params)
  @message = "Entry deleted!"
  haml :success_wo_header, :layout => false
end

##########  Add/Edit Helper Routes ################
get '/clusterdrop' do
  login_required
  @clusters = Cluster.select(:cluster_id, :consensus_sequence).where(:dataset_name => params[:selElem].to_s).all 
  haml :clusterdrop, :layout => false
end

get '/performancesdrop' do
  login_required
  @performances = PeptidePerformance.select(:peptide_sequence).where(:library_name => params[:selElem].to_s).all
  haml :performancesdrop, :layout => false
end

get '/editdrop' do
  login_required
  redirect "/" unless current_user.admin?
  @column = find_id_column(params[:table].to_s) 
  puts params[:table]
  if params[:table] == "targets"
    @data = DB[params[:table].to_sym].select(:target_id, :species, :tissue, :cell).order(:species, :tissue, :cell).all
  else
    @data = DB[params[:table].to_sym].distinct.select(@column)
  end
  haml :editdrop, :layout => false
end

post '/validate-data' do
  login_required
  redirect "/" unless current_user.admin?
  @errors = validate(params)
  @values = params
  unless params[:statfile].nil?
    if params[:tab].nil?
      @values[:overwrite] = false
    else
      @values[:overwrite] = true 
    end
    @errors = save_statfile(@values)
  end
  if @errors.empty?
    if params[:tab].nil?
      @dberrors = insert_data(@values)
      @message = "All data inserted successfully!"
    else
      @dberrors = update_data(@values)
      @message = "Update successful!"
    end
    if @dberrors.empty?
      haml :success, :layout => false
    else
      haml :validation_errors, :layout => false, locals:{errors: @dberrors}
    end
  else
    haml :validation_errors, :layout => false, locals:{errors: @errors}
  end
end

get '/formdrop' do
  login_required
  if (request.referrer.include?("property-search")&& !current_user.admin?)
    @querystring, @placeholders = build_prop_formdrop_string(params)
  else
    @querystring, @placeholders = build_formdrop_string(params)
  end
  req = !params[:required].nil? ? true : false
  @data = DB[params[:table].to_sym].distinct.select(params[:columnname].to_sym).where(Sequel.lit(@querystring, *@placeholders))
  haml :formdrop, :layout => false, locals:{values:@data, column:params[:columnname].to_sym, para:params['boxID'].to_sym, required:req }
end

get '/datalist' do
  login_required
  @querystring, @placeholders = build_formdrop_string(params)
  val = !params[:required].nil? ? true : false
  @data = DB[params[:table].to_sym].distinct.select(params[:columnname].to_sym).where(Sequel.lit(@querystring, *@placeholders))
  haml :datalist, :layout => false, locals:{req: val,label: params[:label].to_s, fieldname: params[:fieldname].to_s,listname: params[:listname].to_s , listlabel:params[:listlabel].to_s, dbdata:@data, columnname:params[:columnname].to_sym  }
end
####### Misc. Routes #############
get '/error' do
  login_required
  @error = {:response => params[:error].to_s}
  haml :validation_errors_wo_header, :layout => false, locals:{errors:@error}
end

get '/datatables' do
  login_required
  content_type :json
  get_datatable_json(params, request.referer)
end

get '/empty' do
  haml :empty, :layout => false
end
###### Sinatra Authentication ######

set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + "views/"

get '/login' do
  haml :login, :layout => false
end

get '/user-management' do
  login_required
  redirect "/" unless current_user.admin?
  @selections = Selection.all
  @users = SequelUser.all
  haml :user_management
end

get '/stats/:ds_name' do
  login_required
  if current_user.admin?
    allowed = 1
  else
    allowed = get_acccessible_elements(:sequencing_datasets)
  end
 
  filename = SequencingDataset.select(:statistic_file).where(:dataset_name => params[:ds_name].to_s).first
  
  if (allowed != 1 || filename == nil || filename[:statistic_file] == nil)
    not_found("file not found")
  else
    output_name = filename[:statistic_file].split('/')[-1] << ".txt"
    send_file filename[:statistic_file], :type => :txt 
  end
end

get '/amino-dist-pdf/:ds_name' do
  login_required
  allowed = false
  if (current_user.admin? || can_access?(:sequencing_datasets, params[:ds_name]))
    allowed = true
  end
  if allowed
    style_path = settings.views + '/style.scss'
    bootstrap_css = settings.public_folder + '/bootstrap/css/bootstrap.css'
    haml_template = File.read(File.join(settings.views, 'amino_dist_table_pdf.haml'))
    begin
      html = Haml::Engine.new(haml_template).render(binding, :distribution => get_amino_acid_dist(params[:ds_name]), :dataset => params[:ds_name])
    rescue ArgumentError => e
      redirect '/'
    end
    kit = PDFKit.new(html)
    kit.stylesheets << style_path 
    kit.stylesheets << bootstrap_css
    content_type :pdf
    kit.to_pdf
  else 
    redirect '/'
  end
end
