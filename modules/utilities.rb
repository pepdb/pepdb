#encoding=utf-8
require 'sinatra/base'
# this module adds some convenience methods

module Sinatra
  module Utilities
    include Rack::Utils
    alias_method :h, :escape_html
    
    # formats domanice in datatables
    def format_dominance(value)
        if value.class != Float
          return ""
        end
        dom = value * 100
        "%E" % dom
    end

    def format_score(value)
        "%.5f" % value 
    end

    def get_permission_description(user)
      if (user.permission_level == -1 || user.site_admin?)
        "admin"
      elsif user.permission_level == 1
        "authenticated user"
      end
    end
    
    def is_dominance?(column)
      column == :dominance || column == :dominance_sum || column == :Dominance || column == :Dominance_sum
    end

    # align numerical values right 
    def align_right?(column)
      numeric_columns = [:Read_length, :Date, :Insert_length, :Distinct_peptides, :Peptide_diversity, :Selection_round, :Sequence_length, :Reads_sum, :Dominance_sum, :Rank, :Reads, :Dominance]
      numeric_columns.include?(column)
    end
  
    def choose_data(params)
      if params['selector'] == "sel"
        datatype = Selection.select(:selection_name).where(:library_name => params['checkedElem'])
        columnname = :selection_name
      elsif params['selector'] == "ds"
        datatype = SequencingDataset.select(:dataset_name).where(:selection_name => params['checkedElem'])
        columnname = :dataset_name
      end

      return datatype, columnname
    end #choose_data
    
    # nbsp = non-breaking space, tests if a value other than the blank field
    # in a dropdown-menu was selected
    def not_just_nbsp?(field)
      field != "" && field.match(/^[[:space:]]+$/) == nil
    end

    def option_selected?(field)
      !field.nil? && not_just_nbsp?(field)
    end
  
    # return all libraries, selecions and sequencing datasets that the current user is allowed
    # to access
    def get_allowed_lib_sel_ds(user)
      allowed_lib = []
      allowed_sel = []
      allowed_ds = []
      DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => user.id).each {|ds| allowed_ds.insert(-1, ds[:dataset_name])}
      DB[:libraries_sequel_users].select(:library_name).where(:id => user.id).each {|ds| allowed_lib.insert(-1, ds[:library_name])}
      DB[:selections_sequel_users].select(:selection_name).where(:id => user.id).each {|ds| allowed_sel.insert(-1, ds[:selection_name])}
      libraries = Library.where(:library_name => allowed_lib)
      selections = Selection.where(:selection_name => allowed_sel)
      datasets = SequencingDataset.where(:dataset_name => allowed_ds)
      
      return libraries, selections, datasets
    end
    
    def calc_gen_spec(spec, ref_specs, cluster_spec, clusters = nil)
      if cluster_spec
        gen_spec = 1
        clusters.each do |cluster|
          gen_spec *= calc_spec_score(spec,ref_specs[cluster][0][:dominance_sum])
        end
        gen_spec
      else
        ref_specs.inject(1){|gen_spec, pep_dom| gen_spec * calc_spec_score(spec,pep_dom) }   
      end
    end
    def calc_spec_score(spec, ref_dom)
      score = 1 - (1 /((spec/ref_dom) + 1 ))
      score
    end


    def get_max_row_length(cluster_per_match, results)
      length =  0
      cluster_per_match.each_value do |row|
        puts row.inspect
        uniq_cl = row.dup.to_set
        cl_sum = 0
        uniq_cl.each do |cluster|
          puts results[cluster].inspect
          puts results[cluster].size
          cl_sum += results[cluster].size
        end
        length = cl_sum if cl_sum > length
      end
      puts length
      length
    end

    def format_comp_cl_data(investigated_cl, cl_to_matches, matched_cl_info, sim_scores, max_row_len)
      table_header = ["Consensus_sequence", "real dom.","Dominance_sum", "General_specifity"]
      table_row = {}
      is_numeric_cell = [false,true,true,true]
      0.upto(max_row_len-1) {|header_cells| table_header.push("Consensus_sequence", "Dataset", "Specifity_score", "real dom", "Dominance_sum", "Similarity_score")}
      investigated_cl.each do |invest|
        invest_cons = invest[:consensus_sequence]
        invest_dom = format_dominance(invest[:dominance_sum])
        invest_spec = format_score(calc_gen_spec(invest[:dominance_sum], matched_cl_info, true,cl_to_matches[invest_cons]))
        table_row[invest_cons] = [invest_cons, invest[:dominance_sum],invest_dom, invest_spec]
        sim_scores[invest_cons].each_pair do |key,value|
          matched_cl_info[key].each do |reference|
            cons = reference[:consensus_sequence]
            ds = reference[:dataset_name]
            spec = format_score(calc_spec_score(invest[:dominance_sum].to_f, reference[:dominance_sum].to_f))
            dom = format_dominance(reference[:dominance_sum])
            sim = format_score(value) 
            table_row[invest_cons].push(cons, ds, spec, reference[:dominance_sum],dom, sim)
            is_numeric_cell.push(false,false,true,true,true,true)
          end 
        end
        num_of_matched_cl = cl_to_matches[invest_cons].size
        if num_of_matched_cl < max_row_len
          cells = (max_row_len - num_of_matched_cl)*6
          0.upto(cells-1) {|emtpy_cell| table_row[invest_cons].push("")}
        end
      end
      return table_row, table_header, is_numeric_cell
    end


    def test_for_nil(value, column)
      if value.nil?
        ""
      else
        puts value.inspect
        value[0][column]
      end
    end
    
    def calc_cluster_read_sums(params)
      reads = []
      cl_peps = []
      params[:ele_name].zip(params[:ele_name2]).each do |cl, ds|
        peps = Cluster.join(:clusters_peptides, :cluster_id => :cluster_id).select(:peptide_sequence).where(:dataset_name => ds.to_s, :consensus_sequence => cl.to_s).all
        reads.push(Observation.where(:dataset_name => ds.to_s, :peptide_sequence => peps.map{|pep| pep[:peptide_sequence]}).sum(:reads))
        cl_peps.push(peps)
      end
      return reads, cl_peps
    end

    def save_statfile(params)
      errors = {}
      filename = h params[:dsname].to_s.tr(' ', '_')
      unless Dir.exists?('statisticfiles/')
        begin
          Dir.mkdir('statisticfiles/')
        rescue SystemCallError => e
          errors[:mkdir] = "can't create statistics directory" 
        end
      end
      filepath = 'statisticfiles/'+filename
      if ( errors.empty? && (!File.exists?(filepath)||  params[:overwrite]))
        File.open(filepath, 'w') do |statfile|
          statfile.write(params[:statfile][:tempfile].read)
        end
        params[:statpath] = filepath 
      else
        errors[:file] = "dataset already exists, try editing it"
      end
      errors
    end



  end #module

  helpers Utilities
end #module
