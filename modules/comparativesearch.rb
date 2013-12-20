require 'sinatra/base'
# this modules implements the comparative peptide search
module Sinatra
  module ComparativeSearch 
  
    def comparative_search(comp_type, reference_sets, comp_set)
      unique_peptides = Array.new
      common_peptides = Array.new
        # get all distinct peptides from reference datasets
        ref_data = Observation.distinct.select(:peptide_sequence).where(:dataset_name => reference_sets).where(Sequel.lit(@ref_qry, *@ref_placeh))
        # the all peptides form first dataset excluding the reference peptides
        unique_peptides = Observation.select(:peptide_sequence, :dataset_name, :dominance).where(:dataset_name => comp_set).where(Sequel.lit(@ds_qry, *@ds_placeh)).exclude(:peptide_sequence => ref_data)
        ds_data = Observation.select(:peptide_sequence).where(:dataset_name => comp_set).where(Sequel.lit(@ds_qry, *@ds_placeh))
        # get all peptides that occure in every dataset selected
        common_peptides = Observation.select(:peptide_sequence).where(:dataset_name => reference_sets, :peptide_sequence => ds_data).where(Sequel.lit(@ref_qry, *@ref_placeh)).group_and_count(:peptide_sequence).having(:count => reference_sets.size)

    return unique_peptides, common_peptides 
    
    end #comparative_search
  end #comparative_search
  helpers ComparativeSearch
end #Sinatra
