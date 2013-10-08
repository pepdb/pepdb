require 'sinatra/base'

module Sinatra
  module  NeighbourSearch 
    class BlosumSearch
      def initialize(sequence, neighbours, peptides)
        @peptides = peptides
        @sequence = sequence.to_s
        @num_neighbours = neighbours.to_i
        @seq_neighbours = []
        @blosum_hash = {}
        @curr_min_val = 0
        @in_clause = []
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
        @peptides = Peptide.all if @peptides.nil?
        @peptides.each do |pep|
          peptide = pep[:peptide_sequence]
          if peptide == @sequence
            next
          end
          compare_length(peptide, @sequence)
        end # peptide
        @seq_neighbours.each do |sequence|
          @in_clause.insert(-1, sequence[1])
        end 
        @in_clause
      end #get_neighbours

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
        seq_a.chars.zip(seq_b.chars).each do |a, b|
          curr_val += @blosum_hash["#{a}#{b}".to_sym]  
        end #zip
        if @seq_neighbours.size < @num_neighbours
          @seq_neighbours.insert(-1,[curr_val, peptide])
          if @seq_neighbours.size == @num_neighbours
            @seq_neighbours.sort{|x,y| y <=> x}
            @curr_min_val = @seq_neighbours[-1][0]
          end #if
        elsif curr_val > @curr_min_val
          @seq_neighbours.pop
          @seq_neighbours.unshift([curr_val, peptide])
          @seq_neighbours.sort!{|x,y| y <=> x}
          @curr_min_val = @seq_neighbours[-1][0]
        end #if


      end #compare_sequence
    end #class
  

    def find_neighbours(seq, number_of_neighbours, qry, placeholder)
      if qry.length > 0
        peptides = Peptide.join(Observation, :peptide_sequence => :peptide_sequence).join(SequencingDataset, :dataset_name => :dataset_name).join(Selection, :selection_name => :selection_name).join(Library, :sequencing_datasets__library_name => :libraries__library_name).left_join(Result, :peptides_sequencing_datasets__result_id => :results__result_id).left_join(:targets___sel_target, :selections__target_id => :sel_target__target_id).left_join(:targets___seq_target, :sequencing_datasets__target_id => :seq_target__target_id).distinct.select(:peptides__peptide_sequence).where(Sequel.lit(qry, *placeholder)).all
      end
      bs = BlosumSearch.new(seq, number_of_neighbours, peptides)
      sequences = bs.get_neighbours
      querystring = ""
      querystring << 'peptides.peptide_sequence IN (' if qry.length == 0
      querystring << 'AND peptides.peptide_sequence IN (' if qry.length > 0
      (0...sequences.size).each do |neighbour_seq|
        querystring << '?, '
      end
      querystring.chop!.chop!
      querystring << ') '
      qry << querystring
      placeholder.insert(-1, *sequences)
    end #find_neigh
  end #module

  helpers NeighbourSearch
end # module
