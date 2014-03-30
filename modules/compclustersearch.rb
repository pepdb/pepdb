require 'sinatra/base'
require settings.root + '/modules/blosum'
module BlosumHelpers
  def get_neighbours
    read_blosum_file
    @references = Cluster.all if @references.nil?
    calc_selfscore
    matching_cluster = Set.new
    cluster_to_matches = {}
    @sequences.each do |con_seq|
      @curr_seq = con_seq
      cluster_to_matches[con_seq] = []
      @seq_neighbours[@curr_seq] = []
      @seq_sim_scores[@curr_seq] = {}
      @references.each do |ref_seq|
        next if ref_seq == con_seq
        compare_length(ref_seq, con_seq)
      end
      @seq_neighbours[@curr_seq].each do |sequence|
        @seq_sim_scores[@curr_seq][sequence[1]] = sequence[2]
        cluster_to_matches[con_seq].insert(-1, sequence[1])
        matching_cluster.add(sequence[1])
      end
      @score_index += 1
    end
    return matching_cluster.to_a, @seq_sim_scores, cluster_to_matches
  end
end
module Sinatra
  module ComparativeClusterSearch 
    class CompClusterSearcher
      
    end #class
    

    # this method should be called from within a route to start the
    # comparative cluster search
    def comp_cluster_search(investigate_ds, references, sim_quot, min_dom_inv, min_dom_ref)
      #investigate = Cluster.select(:consensus_sequence).where(:dataset_name => investigate_ds.to_s).where("dominance_sum > ?", min_dom_inv.to_f).all.map{|s| s[:consensus_sequence].upcase}
      investigate = Cluster.select(:consensus_sequence).where(:dataset_name => investigate_ds.to_s).where("dominance_sum > ?", min_dom_inv.to_f).map(:consensus_sequence)
      #references = Cluster.select(:consensus_sequence).where(:dataset_name => references.to_a.map{|s| s.to_s}).where("dominance_sum > ?", min_dom_ref.to_f).all.map{|s| s[:consensus_sequence].upcase }
      references = Cluster.select(:consensus_sequence).where(:dataset_name => references.to_a.map{|s| s.to_s}).where("dominance_sum > ?", min_dom_ref.to_f).map(:consensus_sequence)
      bs = BlosumSearch.new(investigate, Float::INFINITY,references, sim_quot.to_f)
      bs.extend(BlosumHelpers)
      bs.get_neighbours
    end #comp_cluster_search
  end#module  
  helpers ComparativeClusterSearch 
end #module
