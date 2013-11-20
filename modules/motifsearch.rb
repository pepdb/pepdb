require 'sinatra/base'
# this module implements the peptide motif search
module Sinatra
  module MotifSearch 
  
  class MotifSearcher  
    def initialize(motlist, peptides, dataset, table)
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
        #if motif contains character clases e.g. [AE] substitute them with a placeholder
        # so we calculate the "correct" motif length where each class counts just for one character
        motif_brackets = motif.scan(/(\[\w+\])/) 
        substitutions = {}
        motif_wo_brackets = motif 
        motif_brackets.each_with_index do |bracket, index|
          substitutions["#{index}"] = motif_brackets[index][0]
          motif_wo_brackets = motif_wo_brackets.gsub(/#{Regexp.escape(motif_brackets[index][0])}/, "#{index}")
        end
        # compare each motif with each peptide
        # if the motif is short than the peptide just regexp match it with the peptide
        # if the peptide is longer regexp match each motif substring of length |peptide|
        # with the peptide
        @peptides.each do |element2|
          peptide = element2[:peptide_sequence]
          if  motif_brackets.empty? 
            motif_matches_peptide?(motif, peptide, substitutions, motif)
          else
            motif_matches_peptide?(motif_wo_brackets, peptide, substitutions, motif)
          end #if
        end #each
        if @match_found
          DB[@table].import([:dataset_name, :motif_sequence, :peptide_sequence, :dominance],@matches[motif.to_sym])
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
        length = peptide.size
        diff = motif.size - peptide.size
        (0..diff).each do |index|
          submotif = motif.slice(index, length)
          # substitute the placeholders with the correct character classes
          submotif.gsub!(/\d/, substitutions)
          # substitute the correct regexp wildcard symbol
          submotif.gsub!(/X/, '.')
          regexes.insert(-1, Regexp.new(submotif))              
        end
      end
      regexes.each do |regex|
        unless peptide.match(regex).nil? 
          if @dataset.size == 1
            dominance = Observation.select(:dominance).where(:dataset_name => @dataset, :peptide_sequence => peptide).first[:dominance]  
            @matches[real_motif.to_sym].insert(-1, [@dataset, real_motif, peptide, dominance]) 
          else
            @dataset.each do |ds|
              if Observation.select(:peptide_sequence).where(:dataset_name => ds).count != 0
                dominance = Observation.select(:dominance).where(:dataset_name => ds, :peptide_sequence => peptide).first[:dominance]
                @matches[real_motif.to_sym].insert(-1, [ds, real_motif, peptide, dominance]) 
              end
            end #each
          end #if
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
