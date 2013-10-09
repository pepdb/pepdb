require 'sinatra/base'

module Sinatra
  module ComparativeSearch 
  
    def comparative_search(comp_type, reference_sets, comp_set)
      relevant_peptides = Array.new
      if comp_type == "ds_only"
        ref_data = Observation.distinct.select(:peptide_sequence).where(:dataset_name => reference_sets).where(Sequel.lit(@ref_qry, *@ref_placeh))
        relevant_peptides = Observation.select(:peptide_sequence, :dataset_name, :dominance).where(:dataset_name => comp_set).where(Sequel.lit(@ds_qry, *@ds_placeh)).exclude(:peptide_sequence => ref_data)
        result_qry = comp_set
      elsif comp_type == "ref_and_ds"
        puts reference_sets.size
        ds_data = Observation.select(:peptide_sequence).where(:dataset_name => comp_set).where(Sequel.lit(@ds_qry, *@ds_placeh))
        relevant_peptides = Observation.select(:peptide_sequence).where(:dataset_name => reference_sets, :peptide_sequence => ds_data).where(Sequel.lit(@ref_qry, *@ref_placeh)).group_and_count(:peptide_sequence).having(:count => reference_sets.size)
      end #if

    return relevant_peptides 
    
    end #comparative_search
  end #comparative_search
  helpers ComparativeSearch
end #Sinatra
