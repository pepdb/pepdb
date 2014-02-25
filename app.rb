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
require 'digest/sha1'
require 'date'
require 'sass'
require 'haml'
require 'json'
require './model'
require 'sinatra-authentication'
require 'rack-flash'
require 'set'

Haml::Options.defaults[:format] = :xhtml

set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :public_folder, Proc.new {File.join(root, "public_html")}
set :default_encoding, "utf-8" 

use Rack::Session::Cookie, :expire_after => 3600, :secret => 'Gh6hh91uhMEsmq05h01ec2b4i9BRVj39' 
use Rack::Flash

# column to select in later database queries to create less clutter in the routes
library_columns = [:library_name___name, :carrier, :encoding_scheme, :insert_length]
library_all = [:library_name___name, :encoding_scheme, :carrier, :produced_by, :date, :insert_length, :distinct_peptides, :peptide_diversity]
selection_columns = [:selection_name___selection, :species, :tissue, :cell]
selection_all_columns = [:selection_name___name, :selections__library_name___library, :selections__date, :carrier, :performed_by,:species, :tissue, :cell]
selection_info_columns = [:selection_name___name, :library_name___library, :date, :performed_by,:species, :tissue, :cell]
selection_edit_columns = [:selection_name___name, :library_name___library, :date, :performed_by,:targets__target_id___target]
dataset_columns = [:dataset_name___name, :species, :tissue, :cell ]
dataset_info_columns = [:dataset_name___name, :libraries__library_name___library, :selection_name___selection, :sequencing_datasets__date, :species, :tissue, :cell, :selection_round, :carrier]
dataset_all_columns = [:dataset_name___name, :library_name___library, :selection_name___selection, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :species, :tissue, :cell, :statistic_file]
dataset_edit_columns = [:dataset_name___name, :library_name___library, :selection_name___selection, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :targets__target_id___target, :statistic_file]
peptide_columns = [:peptide_sequence, :rank, :reads , :dominance]
sys_peptide_columns = [:peptides_sequencing_datasets__peptide_sequence, :rank, :reads , :dominance, :sequencing_datasets__dataset_name___dataset]
cluster_peptide_columns = [:clusters_peptides__peptide_sequence, :rank, :reads , :peptides_sequencing_datasets__dominance]
peptide_all_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name, :selection_name, :library_name, :rank, :reads, :dominance, :performance, :species, :tissue, :cell ]
clsearch_results = [:consensus_sequence___consensus, :library_name___library, :selection_name___selection, :dataset_name___dataset]

# Order and naming for info columns shown in the browsing options
library_info = [:library_name___Name, :carrier___Carrier, :insert_length___Insert_length, :encoding_scheme___Encoding_scheme, :produced_by___Produced_by, :date___Date, :distinct_peptides___Distinct_peptides, :peptide_diversity___Peptide_diversity]
selection_info = [:selection_name___Name, :date___Date, :performed_by___Performed_by,:library_name___Library, :species___Species, :tissue___Tissue, :cell___Cell]
dataset_info = [:dataset_name___Name, :date___Date, :produced_by___Peformed_by, :statistic_file___Statistics, :library_name___Library, :selection_name___Selection, :selection_round___Selection_round, :species___Species, :tissue___Tissue, :cell___Cell, :origin___Origin, :sequencer___Sequencer, :read_type___Read_type, :sequence_length___Read_length, :used_indices___Used_barcode]
peptide_info = [:peptides_sequencing_datasets__peptide_sequence___Peptide, :sequencing_datasets__library_name___Library, :selection_name___Selection, :sequencing_datasets__dataset_name___Sequencing_dataset, :rank___Rank, :reads___Reads , :dominance___Dominance, :performance___Peptide_performance ]
dna_info = [:dna_sequences_peptides_sequencing_datasets__dna_sequence___DNA_sequence, :reads___Reads]
cluster_info = [:consensus_sequence___Consensus_sequence, :library_name___Library, :selection_name___Selection, :dataset_name___Sequencing_dataset, :dominance_sum___Dominance_sum, :parameters___Parameters]


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
    allowed = []
    DB[:libraries_sequel_users].select(:library_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:library_name])}
    @libraries = Library.select(*library_columns).where(:library_name => allowed)
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
  elsif can_access?(:libraries, params[:lib_name])
    allowed = []
    DB[:libraries_sequel_users].select(:library_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:library_name])}
    @libraries = Library.select(*library_columns).where(:library_name => allowed)
  else
    redirect '/libraries'
  end
  @selections = Selection.left_join(Target, :target_id=>:target_id).select(*selection_columns)
  #@columns = {"Name" => :library_name, "Carrier"}
  @infodata = Library.select(*library_info)
  haml :libraries
end

get '/selections' do
  login_required
  if current_user.admin?
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns)
  else
    allowed = []
    DB[:selections_sequel_users].select(:selection_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:selection_name])}
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns).where(:selection_name => allowed)
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
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns)
  elsif can_access?(:selections, params[:sel_name])
    allowed = []
    DB[:selections_sequel_users].select(:selection_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:selection_name])}
    @selections = Selection.left_join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns).where(:selection_name => allowed)
  else
    redirect '/selections'
  end
  @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_columns)
  @infodata = Selection.select(*selection_info).left_join(Target, :target_id => :target_id).where(:selection_name => params[:sel_name])
  @eletype = "Selection"
  haml :selections
end

get '/datasets' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns)
  else
    allowed = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:dataset_name])}
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns).where(:dataset_name => allowed)
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
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :libraries__library_name => :sequencing_datasets__library_name).select(*dataset_info_columns)
  elsif can_access?(:sequencing_datasets, params[:set_name])
    allowed = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:dataset_name])}
    @datasets = SequencingDataset.left_join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns).where(:dataset_name => allowed)
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
    @datasets = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| @datasets.insert(-1, ds[:dataset_name])}
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
    @datasets = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| @datasets.insert(-1, ds[:dataset_name])}
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
    @datasets = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| @datasets.insert(-1, ds[:dataset_name])}
    @clusters = Cluster.where(:dataset_name => @datasets)
  else
    redirect "/clusters"
  end
  @cluster_info = Cluster.select(:consensus_sequence, :dominance_sum, :parameters)
 @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
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
    puts params.inspect
    @cluster_infos = Cluster.where(:consensus_sequence => params[:selCl].to_s,:dataset_name => params[:selDS].to_s).select(*cluster_info).all
    @cluster_peps = DB[:clusters_peptides].join(:clusters, :cluster_id=>:cluster_id).select(:peptide_sequence).where(:consensus_sequence => params[:selCl].to_s, :dataset_name => params[:selDS].to_s).all
    @reads_sum = Observation.where(:dataset_name => @cluster_infos[0][:Sequencing_dataset], :peptide_sequence => @cluster_peps.map{|pep| pep[:peptide_sequence]}).sum(:reads)
  else
    @cluster_infos = Cluster.where(:cluster_id => "#{params[:selCl]}").select(*cluster_info).all
    @cluster_peps = DB[:clusters_peptides].select(:peptide_sequence).where(:cluster_id => "#{params[:selCl]}").all
    @reads_sum = Observation.where(:dataset_name => @cluster_infos[0][:Sequencing_dataset], :peptide_sequence => @cluster_peps.map{|pep| pep[:peptide_sequence]}).sum(:reads)
  end
  haml :cluster_infos, :layout => false
end

get '/show_sn_table' do
  login_required
  if params['ref'] == "Library" 
    @column = :library_name
    @eletype = "Selections"
    @id = :show_table
    @data = Selection.left_join(Target, :target_id=>:target_id).select(*selection_columns)
  elsif params['ref'] == "Selection" 
    @column = :selection_name
    @eletype = "Sequencing Datasets"
    @id = :show_table
    @data = SequencingDataset.left_join(Target, :target_id=>:target_id).select(*dataset_columns)
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
    @libraries, @selections, @datasets = get_allowed_lib_sel_ds(current_user) 
  end
  haml :sys_search
end

get '/systemic-results' do
  login_required
  @peptides = Observation.select(:peptide_sequence,:rank, :reads, :dominance, :dataset_name).where(:dataset_name => params['sysDS'])
  haml :peptide_results, :layout => false
end

#------- Property Search -------------#
get '/property-search' do
  login_required
  if current_user.admin?
    @libraries = Library
    @datasets = SequencingDataset
    @selections = Selection
  else
    @libraries, @selections, @datasets = get_allowed_lib_sel_ds(current_user) 
  end
  @targets = Target
  haml :prop_search
end

get '/property-results' do
  login_required
  @results = Observation.join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(:targets___sel_target, :selections__target_id => :sel_target__target_id).left_join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).select(*sys_peptide_columns)
  begin
    @querystring, @placeholders = build_property_array(params)
    if option_selected?(params[:blos])
      raise ArgumentError, "similarity quotient must be between 0 and 1" if (params[:sq].to_f < 0 || params[:sq].to_f > 1)
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
    @libraries, @selections, @datasets = get_allowed_lib_sel_ds(current_user) 
  end
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*sys_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
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
    allowed = []
    DB[:libraries_sequel_users].select(:library_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:library_name])}
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
  case params[:selector]
  when "sel"
    table = :libraries
  when "ds"
    table = :selections
  end
  if params[:checkedElem].nil?
  elsif current_user.admin? || can_access?(table, params[:checkedElem])
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
    allowed = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:dataset_name])}
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
    allowed = []
    DB[:libraries_sequel_users].select(:library_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:library_name])}
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
    #puts @scores.inspect
    #puts "-------------------------------------------------------"
    #puts @match_cl.inspect
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    #puts @cluster_to_matches.inspect
    @tab_rows, @header, @is_numeric_cell = format_comp_cl_data(@investigated_cl, @cluster_to_matches, @match_cl,@scores, @max_length)
    puts @tab_header.inspect
    puts @tab_rows.inspect
    puts @is_numeric_cell.inspect
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
  @schemes = Library.distinct.select(:encoding_scheme)
  @carriers = Library.distinct.select(:carrier)
  @producers = Library.distinct.select(:produced_by)
  haml :library_form, :layout => false
end
get '/addselection' do
  login_required
  redirect "/" unless current_user.admin?
  @libraries = Library.distinct.select(:library_name)
  @performs = Selection.distinct.select(:performed_by)
  @species = Target.distinct.select(:species)
  haml :selection_form, :layout => false
end
get '/adddataset' do
  login_required
  redirect "/" unless current_user.admin?
  @ds_infos = SequencingDataset.select(:read_type , :used_indices, :origin, :produced_by, :sequencer, :selection_round, :sequence_length)
  @libraries = Library
  @selections = Selection
  @species = Target.distinct.select(:species)
  haml :dataset_form, :layout => false
end
get '/addperformance' do
  login_required
  redirect "/" unless current_user.admin?
  @libraries = Library
  haml :performance_form, :layout => false
end
get '/addtarget' do
  login_required
  redirect "/" unless current_user.admin?
  @species = Target.distinct.select(:species)
  @tissues = Target.distinct.select(:tissue)
  @cells = Target.distinct.select(:cell)
  haml :target_form, :layout => false
end

get '/addcluster' do
  login_required
  redirect "/" unless current_user.admin?
  @libraries = Library
  @selection = Selection
  @datasets = SequencingDataset
  haml :cluster_form, :layout => false
end

get '/addmotif' do
  login_required
  redirect "/" unless current_user.admin?
  haml :motif_form, :layout => false
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
  @schemes = Library.distinct.select(:encoding_scheme)
  @carriers = Library.distinct.select(:carrier)
  @producers = Library.distinct.select(:produced_by)
  @library = Library.select(*library_all).where(:library_name => params[:selElem].to_s).first 
  haml :edit_libraries, :layout => false
end

get '/editselections' do
  login_required
  redirect "/" unless current_user.admin?
  @species = Target.distinct.select(:species)
  @performs = Selection.distinct.select(:performed_by)
  @selection = Selection.select(*selection_edit_columns).left_join(Target, :target_id => :target_id).where(:selection_name => params[:selElem].to_s).first
  @target = @selection[:target]
  @libraries = Library.all
  haml :edit_selections, :layout => false
end

get '/editsequencing-datasets' do
  login_required
  redirect "/" unless current_user.admin?
  @dataset = SequencingDataset.select(*dataset_edit_columns).left_join(Target, :target_id => :target_id).where(:dataset_name => params[:selElem].to_s).first
  @libraries = Library
  @selections = Selection
  @ds_infos = SequencingDataset.select(:read_type , :used_indices, :origin, :produced_by, :sequencer, :selection_round, :sequence_length)
  @target = @dataset[:target]
  haml :edit_datasets, :layout => false
end

get '/edittargets' do
  login_required
  redirect "/" unless current_user.admin?
  @target = Target.select(:species, :tissue, :cell).where(:target_id => params[:selElem].to_i).first
  @species = Target.distinct.select(:species)
  @tissues = Target.distinct.select(:tissue)
  @cells = Target.distinct.select(:cell)
  haml :edit_targets, :layout => false
end
get '/editperformances' do
  login_required
  redirect "/" unless current_user.admin?
  @performance = PeptidePerformance.select(:performance, :library_name, :peptide_sequence).where(:library_name => params[:selLib].to_s, :peptide_sequence => params[:selElem].to_s).first
  @libraries = Library
  haml :edit_performances, :layout => false
end

get '/editmotif-lists' do
  login_required
  redirect "/" unless current_user.admin?
  @motlist = DB[:motifs_motif_lists].select(:motif_sequence, :target, :receptor, :source).where(:list_name => params[:selElem].to_s)
  haml :edit_motiflists, :layout => false
end

get '/editclusters' do
  login_required
  redirect "/" unless current_user.admin?
  @datasets = SequencingDataset.all
  @cluster = Cluster.select(:parameters, :dataset_name, :cluster_id).where(:cluster_id => params[:selElem]).first
  @peptides = DB[:clusters_peptides].select(:peptide_sequence).where(:cluster_id => params[:selElem])
  haml :edit_clusters, :layout => false
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
  @data = DB[params[:table].to_sym].distinct.select(@column)
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
  @querystring, @placeholders = build_formdrop_string(params)
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
    allowed = DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id, :dataset_name => params[:ds_name].to_s).count
  end
 
  filename = SequencingDataset.select(:statistic_file).where(:dataset_name => params[:ds_name].to_s).first
  
  if (allowed != 1 || filename == nil || filename[:statistic_file] == nil)
    not_found("file not found")
  else
    output_name = filename[:statistic_file].split('/')[-1] << ".txt"
    send_file filename[:statistic_file], :type => :txt 
  end
end