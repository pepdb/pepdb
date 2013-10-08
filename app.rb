#pepdb.rb
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

Haml::Options.defaults[:format] = :xhtml

set :environment, :development
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :public_folder, Proc.new {File.join(root, "public_html")}

use Rack::Session::Cookie, :secret => 'better secret needeQ!'

use Rack::Flash

class SequelUser
  String :name
end


library_columns = [:library_name___name, :carrier, :encoding_scheme, :insert_length]
library_all = [:library_name___name, :encoding_scheme, :carrier, :produced_by, :date, :insert_length, :distinct_peptides, :peptide_diversity]
selection_columns = [:selection_name___selection, :species, :tissue, :cell]
selection_all_columns = [:selection_name___name, :selections__library_name___library, :selections__date, :carrier, :performed_by,:species, :tissue, :cell]
selection_info_columns = [:selection_name___name, :library_name___library, :date, :performed_by,:species, :tissue, :cell]
dataset_columns = [:dataset_name___name, :species, :tissue, :cell ]
dataset_info_columns = [:dataset_name___name, :libraries__library_name___library, :selection_name___selection, :sequencing_datasets__date, :species, :tissue, :cell, :selection_round, :carrier]
dataset_all_columns = [:dataset_name___name, :library_name___library, :selection_name___selection, :date, :selection_round, :sequence_length, :read_type, :used_indices, :origin, :sequencer, :produced_by, :species, :tissue, :cell, :statistics]
peptide_columns = [:peptides__peptide_sequence, :rank, :reads , :dominance]
sys_peptide_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name___dataset,:rank, :reads , :dominance]
cluster_peptide_columns = [:clusters_peptides__peptide_sequence, :rank, :reads , :peptides_sequencing_datasets__dominance]
peptide_all_columns = [:peptides__peptide_sequence, :sequencing_datasets__dataset_name, :selection_name, :library_name, :rank, :reads, :dominance, :performance, :species, :tissue, :cell ]
dna_columns = [:dna_sequences__dna_sequence, :reads]


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
  haml :libraries
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
    @selections = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  @infodata = Library.select(*library_all)
  haml :libraries
end

get '/selections' do
  login_required
  if current_user.admin?
    @selections = Selection.join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns)
  else
    allowed = []
    DB[:selections_sequel_users].select(:selection_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:selection_name])}
    @selections = Selection.join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns).where(:selection_name => allowed)
  end
  haml :selections
end

get '/selections/:sel_name' do
  login_required
  if current_user.admin?
    @selections = Selection.join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns)
  elsif can_access?(:selections, params[:sel_name])
    allowed = []
    DB[:selections_sequel_users].select(:selection_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:selection_name])}
    @selections = Selection.join(Target, :target_id=>:target_id).join(Library, :selections__library_name => :libraries__library_name).select(*selection_all_columns).where(:selection_name => allowed)
  else
    redirect '/selections'
  end
  @datasets = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  @infodata = Selection.select(*selection_info_columns).join(Target, :target_id => :target_id).where(:selection_name => params[:sel_name])
  haml :selections
end

get '/datasets' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns)
  else
    allowed = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:dataset_name])}
    @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns).where(:dataset_name => allowed)
  end
  haml :datasets
end

get '/datasets/:set_name' do
  login_required
  if current_user.admin?
    @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :libraries__library_name => :sequencing_datasets__library_name).select(*dataset_info_columns)
  elsif can_access?(:selections, params[:sel_name])
    allowed = []
    DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).each {|ds| allowed.insert(-1, ds[:dataset_name])}
    @datasets = SequencingDataset.join(Target, :target_id=>:target_id).join(Library, :sequencing_datasets__library_name => :libraries__library_name).select(*dataset_info_columns).where(:dataset_name => allowed)
  else
    redirect '/datasets'
  end
  @peptides = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  @infodata = SequencingDataset.select(*dataset_all_columns).join(Target, :target_id => :target_id).where(:dataset_name => params[:set_name])
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
  @cluster_info = Cluster.select(:consensus_sequence, :dominance, :parameters)
 @cluster_pep = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).join(Observation, :peptide_sequence => :peptide_sequence).select(*cluster_peptide_columns)
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :clusters
end

####### Data Browsing Helper Routes ####################

get '/show_sn_table' do
  login_required
  if params['ref'] == "Library" 
    @column = :library_name
    @eletype = "Selections"
    @id = :show_table
    @data = Selection.join(Target, :target_id=>:target_id).select(*selection_columns)
  elsif params['ref'] == "Selection" 
    @column = :selection_name
    @eletype = "Sequencing Datasets"
    @id = :show_table
    @data = SequencingDataset.join(Target, :target_id=>:target_id).select(*dataset_columns)
  elsif params['ref'] == "Sequencing Dataset" 
    @column = :sequencing_datasets__dataset_name
    @eletype = "Peptides"
    @id = :pep_table
    @data = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name___dataset=>:dataset_name).select(*peptide_columns)
  end
  haml :show_sn_table, :layout => false
end

get '/info-tables' do
  login_required
  if request.referer.include?("libraries")
    @infodata = Library.select(*library_all).where(:library_name => params[:infoElem])
  elsif request.referer.include?("selection")
    @infodata = Selection.select(*selection_info_columns).join(Target, :target_id => :target_id).where(:selection_name => params[:infoElem])
  elsif request.referer.include?("datasets")
    @infodata = SequencingDataset.select(*dataset_all_columns).join(Target, :target_id => :target_id).where(:dataset_name => params[:infoElem])
  end
  haml :info_tables, :layout => false, locals:{data_to_display:@infodata, element:"#{h params[:infoElem]}"}
end

get '/show-info' do
  login_required
  if params['ref'] == "Library"
    @info_data = Selection.join(Target, :target_id=>:target_id).select(*selection_info_columns)
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
    @peptide_dna = Peptide.join(DNAFinding, :peptide_sequence=>:peptide_sequence).join(SequencingDataset, :dataset_name =>:dataset_name).join(DnaSequence, :dna_sequence=>:dna_sequences_peptides_sequencing_datasets__dna_sequence).select(*dna_columns)
    @eletype = "Peptide"
    @column1 = :peptides__peptide_sequence
    @column2 = :sequencing_datasets__dataset_name
  end
  haml :show_info, :layout => false
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
  @peptides = Observation.select(:peptide_sequence,:dataset_name,:rank, :reads, :dominance).where(:dataset_name => params['sysDS'])
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
  @results = Peptide.join(Observation, :peptide_sequence => :peptide_sequence).join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).join(:targets___sel_target, :selections__target_id => :sel_target__target_id).join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).select(*sys_peptide_columns)
  begin
    @querystring, @placeholders = build_property_array(params)
    DB.create_table?(:propqry) do
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

post '/comparative-results' do
  login_required
  @ref_qry, @ref_placeh = build_rdom_string(params)
  @ds_qry, @ds_placeh = build_cdom_string(params)
  @peptides = comparative_search(params[:comp_type], params[:ref_ds], params[:radio_ds])
  
  haml :peptide_results, :layout => false
end

post '/peptide-infos' do
  login_required
  @peptide_info = Peptide.join(Observation, :peptide_sequence___peptide=>:peptide_sequence___peptide).join(SequencingDataset, :dataset_name=>:dataset_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(Target, :targets__target_id => :results__target_id).select(*peptide_all_columns)
  haml :peptide_infos, :layout => false
end

# -------- Motif Search ----------- #

get '/motif-search' do
  login_required
  @libraries = Library
  @motiflists = MotifList
  haml :motif_search
end

post '/motif-search' do
  login_required
  @libraries = Library.all
  @datasets = SequencingDataset
  @selections = Selection
  haml :motif_search
end

get '/mot-checklist' do
  login_required
  @motlists = DB[:motifs_motif_lists].distinct.select(:motif_sequence, :target, :receptor, :source).where(:list_name => params[:checkedElem])
  haml :mot_checklist, :layout => false
end

get '/motif-search-results' do
  login_required
  @errors = {}
  if params[:ref_ds].nil?
    @errors[:dataset] = "no dataset selected!" 
  elsif params[:checked_motl].nil?
    @errors[:motl] = "no motif list selected!" 
  end
  if @errors.empty?
    DB.create_table?(:mot_matches, :temp => true) do
      String :motif_sequence
      String :dataset_name
      String :peptide_sequence
      primary_key [:motif_sequence, :peptide_sequence, :dataset_name]
      index [:motif_sequence, :peptide_sequence, :dataset_name]
    end
    @table = :mot_matches
    @datasets = params[:ref_ds]
    @peptides = Observation.distinct.select(:peptide_sequence).where(:dataset_name => @datasets)
    @motlists = DB[:motifs_motif_lists].distinct.select(:motif_sequence).where(:list_name => params[:checked_motl])
    
    search_peptide_motif_matches(@motlists, @peptides, @datasets, @table)
    @results = DB[@table].distinct.select(:motif_sequence, :peptides_sequencing_datasets__peptide_sequence___peptide, :peptides_sequencing_datasets__dataset_name___dataset, :rank).left_join(:peptides_sequencing_datasets, :peptide_sequence => :peptide_sequence)
    haml :mot_search_res, :layout => false
  else
    haml :validation_errors, :layout => false, locals:{errors:@errors}
  end
end

#----------- Peptide Search Helper Routes -----------#
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

post '/cluster-results' do
  login_required
  @cluster = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).select(:clusters__cluster_id___id ,:consensus_sequence___consensus, :library_name___library, :selection_name___selection, :dataset_name___dataset )
  haml :peptide_results, :layout => false
end

post '/cluster-infos' do
  login_required
  @cluster_infos = Cluster.where(:cluster_id => "#{params[:selCl]}")
  @cluster_peps = DB[:clusters_peptides].select(:peptide_sequence).where(:cluster_id => "#{params[:selCl]}")
  haml :cluster_infos, :layout => false
end

#------- Comparative Cluster Search ------------#


get '/comparative-cluster-search' do
  login_required
  @libraries = Library
  haml :comparative_cluster_search
end

get '/comparative-cluster-results' do
  login_required
  @errors = {}
  if params[:ref_ds].nil? || params[:ref_ds].size < 2
    @errors[:ds] = "select two or more datasets!"
  elsif params[:comptype].nil?
    @errors[:type] = "no search type selected!" 
  elsif params[:comptype] == "threshold" && params[:domthr].empty?
    @errors[:thr] = "no dominance threshold selected!" 
  end

  if @errors.empty?
    @columns = Cluster.select(:consensus_sequence, :dominance_sum___dominance).first
    @datasets = params[:ref_ds]
    @results = comp_cluster_search(params)
    @clusters = Cluster.select(:dataset_name, :dominance_sum)
    haml :comparative_cluster_results, :layout => false
  else
    haml :validation_errors, :layout => false, locals:{errors:@errors}
  end
end


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
get '/addresult' do
  login_required
  redirect "/" unless current_user.admin?
  @datasets = SequencingDataset
  @species = Target.distinct.select(:species)
  haml :result_form, :layout => false
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
  @selection = Selection.select(*selection_info_columns).join(Target, :target_id => :target_id).where(:selection_name => params[:selElem].to_s).first
  @libraries = Library.all
  haml :edit_selections, :layout => false
end

get '/editsequencing-datasets' do
  login_required
  redirect "/" unless current_user.admin?
  @dataset = SequencingDataset.select(*dataset_all_columns).join(Target, :target_id => :target_id).where(:dataset_name => params[:selElem].to_s).first
  @libraries = Library
  @selections = Selection
  @ds_infos = SequencingDataset.select(:read_type , :used_indices, :origin, :produced_by, :sequencer, :selection_round, :sequence_length)
  @species = Target.distinct.select(:species)
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
get '/editresults' do
  login_required
  redirect "/" unless current_user.admin?
  @result = Result.select(:performance, :species, :tissue, :cell, :dataset_name___dataset, :peptide_sequence).join(Target, :target_id => :target_id).left_join(Observation, :results__result_id => :peptides_sequencing_datasets__result_id).where(:results__result_id => params[:selElem].to_i).first
  @datasets = SequencingDataset
  @species = Target.distinct.select(:species)
  haml :edit_results, :layout => false
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
  @clusters = Cluster.select(:cluster_id, :consensus_sequence).where(:dataset_name => params[:selElem].to_s) 
  haml :clusterdrop, :layout => false
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
  if @errors.empty?
    if params[:tab].nil?
      @dberrors = insert_data(@values)
      @message = "All data inserted successfully!"
    else
      @dberrors = update_data(@values)
      @message = "Update successfull!"
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
