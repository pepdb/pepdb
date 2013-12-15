require 'sinatra/base'
# this module implements the neighbour search thats offered by 
# the peptide property search

module Sinatra
  module  NeighbourSearch 
    class BlosumSearch
      def initialize(sequence, neighbours, peptides, sim_quot)
        @references = peptides
        @sequences = [*sequence].map{|s| s.to_s}
        @curr_seq = @sequences[0]
        @num_neighbours = neighbours.to_i
        @seq_neighbours = {@curr_seq => []}
        @blosum_hash = {}
        @curr_min_val = 0
        @in_clause = []
        @min_sim = sim_quot
        @selfscores = []
        @score_index = 0
        @seq_sim_scores = {@curr_seq => {}}
      end #initilize

      def read_blosum_file
        toplinematch = []
        bf = File.new("./public_html/BLOSUM62")
        lines = bf.readlines
        lines.each do |line|
          if line[0].match(/[#\*]/)
            next
          elsif line[0].match(/\s/)
            toplinematch = line.scan(/\w/)
          else
            curr_aa = line[0]
            aa_linematch = line.scan(/-?\d/)
            toplinematch.each_with_index do |aa, index|
              @blosum_hash["#{curr_aa}#{aa}".to_sym] = aa_linematch[index].to_i
            end #aa
          end #if
        end #line
      end #read_blosum
      
      def get_neighbours
        read_blosum_file
        @references = Peptide.all if @references.nil?
        calc_selfscore
        @references.each do |pep|
          peptide = pep[:peptide_sequence]
          if peptide == @sequences[0]
            next
          end
          compare_length(peptide, @sequences[0])
        end # peptide
        @seq_neighbours[@curr_seq].each do |sequence|
          @seq_sim_scores[@curr_seq][sequence[1]] = sequence[2]
          @in_clause.insert(-1, sequence[1])
        end 
        return @in_clause, @seq_sim_scores[@curr_seq]
      end #get_neighbours

      def calc_selfscore
        @sequences.each do |seq|
          curr_val = 0
          seq.chars.zip(seq.chars).each do |a, b|
            curr_val += @blosum_hash["#{a}#{b}".to_sym]  
          end #zip
          @selfscores.insert(-1, curr_val)
        end
      end

      # preparations for blosum scoring
      # if given sequence and current peptid are of equal length just calculate blosum score
      # if their lengths differ compare each substring of the longer seqence against the shorter one
      def compare_length(peptide, sequence)
        if peptide.size == sequence.size
          compare_sequence(peptide, sequence, peptide)
        else 
          if peptide.size > sequence.size
            longer = peptide
            shorter = sequence
          else
            longer = sequence
            shorter = peptide
          end
          diff = longer.size - shorter.size
          length = shorter.size
          (0..diff).each do |index|
            compare_sequence(longer.slice(index, length), shorter, peptide)      
          end #index
        end #if
      end #compare length
    
      def compare_sequence(seq_a, seq_b, peptide)
        curr_val = 0
        # calculate blosum score
        seq_a.chars.zip(seq_b.chars).each do |a, b|
          curr_val += @blosum_hash["#{a}#{b}".to_sym]  
        end #zip
        sim_quot = curr_val / @selfscores[@score_index].to_f
        if (@seq_neighbours[@curr_seq].size < @num_neighbours && sim_quot > @min_sim)
          @seq_neighbours[@curr_seq].insert(-1,[curr_val, peptide, sim_quot])
          if @seq_neighbours[@curr_seq].size == @num_neighbours
            @seq_neighbours[@curr_seq].sort{|x,y| y <=> x}
            @curr_min_val = @seq_neighbours[@curr_seq][-1][0]
          end #if
        # if we find a sequence with a better blosum score than the current worst 
        # score in the result, replace it
        elsif (curr_val > @curr_min_val && sim_quot > @min_sim )
          @seq_neighbours[@curr_seq].pop
          @seq_neighbours[@curr_seq].unshift([curr_val, peptide, sim_quot])
          @seq_neighbours[@curr_seq].sort!{|x,y| y <=> x}
          @curr_min_val = @seq_neighbours[@curr_seq][-1][0]
        end #if

      end #compare_sequence
    end #class
  

    def find_neighbours(seq, number_of_neighbours, quot, qry, placeholder)
      # if other parameters than just the neighbour search where given
      # get all peptides corresponding to this criteria to reduce search space
      if qry.length > 0
        peptides = Observation.join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(:targets___sel_target, :selections__target_id => :sel_target__target_id).left_join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).distinct.select(:peptides_sequencing_datasets__peptide_sequence).where(Sequel.lit(qry, *placeholder)).all
      end
      bs = BlosumSearch.new(seq, number_of_neighbours, peptides, quot)
      sequences, quotients = bs.get_neighbours
      raise ArgumentError, "no peptide similarity score matches similarity quotient. Try lowering the quotient." if (sequences.empty? || quotients.empty?)
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
      puts quotients.inspect
      quotients
    end #find_neigh
  end #module

  helpers NeighbourSearch
end # module
