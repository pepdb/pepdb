require 'sinatra/base'

module Sinatra
  module AminoAcidDistribution 
    
    def calculate_aa_distr(dataset)
      library = SequencingDataset.select(:library_name).where(:dataset_name => dataset.to_s).first
      pep_length = Library.select(:insert_length).where(:library_name => library[:library_name]).first[:insert_length]
      pep_length = 7 if pep_length == 0
      amino_acids = [:A , :R , :N , :D , :C , :E , :Q , :G , :H , :I , :L , :K , :M , :F , :P , :S , :T , :W , :Y , :V ]
      abs_aa_distr = Hash.new{|h,k| h[k] = init_array(pep_length)}
      aa_distr = Hash.new{|h,k| h[k] = init_array(pep_length)}
      amino_acids.each do |acid|
        abs_aa_distr[acid]
        aa_distr[acid]
      end
      peptides = Observation.select(:peptide_sequence___seq).where(:dataset_name => dataset.to_s).all
      peptide_count = Observation.select(:peptide_sequence___seq).where(:dataset_name => dataset.to_s).count
      puts peptide_count
      peptides.each do |peptide|
        index = 0
        peptide[:seq].each_char do |acid|
          break if index >= pep_length
          abs_aa_distr[acid.to_sym][index] += 1
          index += 1
        end #each
      end #each
      abs_aa_distr.each_pair do |acid , distr|
        distr.each_with_index do |value, index|
          puts value / peptide_count.to_f
          aa_distr[acid][index] = value / peptide_count.to_f
        end #each
      end #each      
      puts aa_distr
    end #calc


    def init_array(size)
      return Array.new(size){|index| index = 0}
    end

  end #module
  helpers AminoAcidDistribution
end #module
