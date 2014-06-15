require 'sinatra/base'
require settings.root + '/modules/blosum'
# this module implements the neighbour search thats offered by 
# the peptide property search
module Sinatra
  module  NeighbourSearch 
  

    def find_neighbours(seq, number_of_neighbours, quot, qry, placeholder)
      # if other parameters than just the neighbour search where given
      # get all peptides corresponding to this criteria to reduce search space
      if qry.length > 0
        peptides = Observation.join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(:targets___sel_target, :selections__target_id => :sel_target__target_id).left_join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).distinct.select(:peptides_sequencing_datasets__peptide_sequence).where(Sequel.lit(qry, *placeholder)).all
      end
      bs = BlosumSearch.new(seq, number_of_neighbours.to_i, peptides, quot, settings.public_folder)
      sequences, quotients = bs.get_neighbours
      raise ArgumentError, "no peptide similarity score reaches similarity quotient. Try adjusting the search parameters." if (sequences.empty? || quotients.empty?)
      querystring = ""
      querystring << 'peptides_sequencing_datasets.peptide_sequence IN (' if qry.length == 0
      querystring << 'AND peptides_sequencing_datasets.peptide_sequence IN (' if qry.length > 0
      (0...sequences.size).each do |neighbour_seq|
        querystring << '?, '
      end
      querystring.chop!.chop!
      querystring << ') '
      qry << querystring
      placeholder.insert(-1, *sequences)
      quotients
    end #find_neigh
  end #module

  helpers NeighbourSearch
end # module
