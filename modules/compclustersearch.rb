require 'sinatra/base'
require './modules/blosum'
module BlosumHelpers
  def get_neighbours
    read_blosum_file
    @references = Cluster.all if @references.nil?
    calc_selfscore
    @sequences.each do |con_seq|
      @curr_seq = con_seq
      @seq_neighbours[@curr_seq] = []
      @seq_sim_scores[@curr_seq] = {}
      @references.each do |ref_seq|
        next if ref_seq == con_seq
        compare_length(ref_seq, con_seq)
      end
      @seq_neighbours[@curr_seq].each do |sequence|
        @seq_sim_scores[@curr_seq][sequence[1]] = sequence[2]
        @in_clause.insert(-1, sequence[1])
      end
      @score_index += 1
    end
    return @in_clause, @seq_sim_scores
  end
end
module Sinatra
  module ComparativeClusterSearch 
    class CompClusterSearcher
      
    end #class
    

    # this method should be called from within a route to start the
    # comparative cluster search
    def comp_cluster_search(investigate_ds, references, sim_quot, min_dom_inv, min_dom_ref)
      investigate = Cluster.select(:consensus_sequence).where(:dataset_name => investigate_ds.to_s).where("dominance_sum > ?", min_dom_inv.to_f).all.map{|s| s[:consensus_sequence].upcase}
      references = Cluster.select(:consensus_sequence).where(:dataset_name => references.to_a.map{|s| s.to_s}).where("dominance_sum > ?", min_dom_ref.to_f).all.map{|s| s[:consensus_sequence].upcase }
      bs = BlosumSearch.new(investigate, Float::INFINITY,references, sim_quot.to_f)
      bs.extend(BlosumHelpers)
      bs.get_neighbours
    end #comp_cluster_search
  end#module  
  helpers ComparativeClusterSearch 
end #module
