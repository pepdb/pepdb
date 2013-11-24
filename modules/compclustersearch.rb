require 'sinatra/base'
module Sinatra
  module ComparativeClusterSearch 
    class CompClusterSearcher
      attr_reader :uniq_results, :comm_results
      def initialize(datasets, threshold = nil)
        @uniq_results = {}
        @datasets = datasets
        @threshold = threshold
        @comm_results = []
      end #init
   

      def uniq_search
        @datasets.each_with_index do |ds, index|
          filter_ds = @datasets.dup
          filter_ds.delete_at(index)
          # select clusters that belong to the reference datasets
          other = Cluster.select(:consensus_sequence).where(:dataset_name => filter_ds.to_a.map{|fds| fds.to_s})
          # select all clusters in first dataset minus clusters with a consensus sequence equal to "other"
          clusters =  Cluster.select(:consensus_sequence, :dominance_sum).where(:dataset_name => ds.to_s).exclude(:consensus_sequence => other).all 
          @uniq_results[ds.to_sym] = clusters
        end #each
      end #uniq_search
      
      def common_search
        # get array with unique consensus sequences from all datasets and 
        # a count of clusters containing the specific sequence
        common_seqs_count = Cluster.where(:dataset_name => @datasets.to_a.map{|ds| ds.to_s}).group_and_count(:consensus_sequence)
        common_seqs = []
        # only use clusters that are present in each selected dataset
        # number of cluster => datasets
        common_seqs_count.each do |seq| 
          common_seqs.insert(-1, seq[:consensus_sequence]) if seq[:count] >= @datasets.size
        end #each
        # build a hash where the keys are all relevant cluster sequences
        # and values are the dominances of all clusters with that sequence
        comm_seq_dominances = Cluster.where(:consensus_sequence => common_seqs).to_hash_groups(:consensus_sequence, :dominance_sum)
        # test for each key if all dominaces are within the given threshold
        comm_seq_dominances.each do |key, value|
          if dominances_in_threshold?(value, @threshold)
            @comm_results.insert(-1, key)
          end
        end #each
      end #common
  
      def dominances_in_threshold?(dominances, threshold)
        within_threshold = true
        dominances.each_with_index do |ref, index|
          dominances.each do |comp|
            unless (ref - comp).abs < threshold
              within_threshold = false
            end #unless
          end #each
        end #each
        within_threshold
      end #threshold?

      
    end #class
    

    def find_unique_clusters(datasets)
      cs = CompClusterSearcher.new(datasets)
      cs.uniq_search
      cs.uniq_results
    end #find_unique

    def find_common_clusters(datasets, threshold)
      cs = CompClusterSearcher.new(datasets, threshold)
      cs.common_search
      cs.comm_results
    end #find_common)
    
    # this method should be called from within a route to start the
    # comparative cluster search
    def comp_cluster_search(params)
      if params[:comptype] == "unique"
        results = find_unique_clusters(params[:ref_ds])
      elsif params[:comptype] == "threshold"
        results = find_common_clusters(params[:ref_ds], params[:domthr].to_f)
      end
    end #comp_cluster_search
  end#module  
  helpers ComparativeClusterSearch 
end #module
