require 'sinatra/base'

module Sinatra
  module MotifSearch 
  
  class MotifSearcher  
    def initialize(motlist, peptides, dataset, table)
      puts dataset
      @table = table.to_sym
      @peptides = peptides
      @dataset = dataset
      @motifs = motlist
      @matches = {}
      @match_found = false
      @motifs.each do |motif|
        @matches[motif[:motif_sequence].to_sym] = []
      end
    end #init

    def find_hits
      @motifs.each do |element|
        motif = element[:motif_sequence]
        motif_brackets = motif.scan(/(\[\w+\])/) 
        substitutions = {}
        motif_wo_brackets = motif 
        motif_brackets.each_with_index do |bracket, index|
          substitutions["#{index}"] = motif_brackets[index][0]
          motif_wo_brackets = motif_wo_brackets.gsub(/#{Regexp.escape(motif_brackets[index][0])}/, "#{index}")
        end
        @peptides.each do |element2|
          peptide = element2[:peptide_sequence]
          if  motif_brackets.empty? 
            motif_matches_peptide?(motif, peptide, substitutions, motif)
          else
            motif_matches_peptide?(motif_wo_brackets, peptide, substitutions, motif)
          end #if
        end #each
        if @match_found
          DB[@table].import([:dataset_name, :motif_sequence, :peptide_sequence],@matches[motif.to_sym])
          @match_found = false
        end
      end #each
    end #find_hits

    def motif_matches_peptide?(motif, peptide, substitutions, real_motif)
      regexes = []
      if motif.size <= peptide.size
        motif = motif.gsub(/X/, '.')
        motif = motif.gsub(/\d/, substitutions)
        regexes.insert(-1, Regexp.new(motif))
      else
        puts "here"
        length = peptide.size
        diff = motif.size - peptide.size
        (0..diff).each do |index|
          submotif = motif.slice(index, length)
          submotif.gsub!(/\d/, substitutions)
          submotif.gsub!(/X/, '.')
          regexes.insert(-1, Regexp.new(submotif))              
        end
      end
      regexes.each do |regex|
        puts regex.inspect
        unless peptide.match(regex).nil? 
          @matches[real_motif.to_sym].insert(-1, [@dataset, real_motif, peptide]) 
          @match_found = true
          break
        end   
      end
    end #mot_matches..
  end #class
  
  def search_peptide_motif_matches(list, peptides, dataset, table)
    ms = MotifSearcher.new(list, peptides,dataset,table)
    ms.find_hits
  end
  
  end #module

  helpers MotifSearch
end #module
