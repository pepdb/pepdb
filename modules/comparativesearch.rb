require 'sinatra/base'

module Sinatra
  module ComparativeSearch 
  
    def comparative_search(comp_type, reference_sets, comp_set)
      relevant_peptides = Array.new
        ds_data = Observation.select(:peptide_sequence).where(:dataset_name => comp_set).where(Sequel.lit(@ds_qry, *@ds_placeh))
      if comp_type == "ds_only"
        ref_data = Observation.distinct.select(:peptide_sequence).where(:dataset_name => params[:ref_ds]).where(Sequel.lit(@ref_qry, *@ref_placeh))
        ds_only_search(reference_sets, ref_data, ds_data, relevant_peptides)
        result_qry = comp_set
      elsif comp_type == "ref_and_ds"
        ref_data = Observation.select(:peptide_sequence).where(:dataset_name => params[:ref_ds]).where(Sequel.lit(@ref_qry, *@ref_placeh))
        ds_and_ref_search(reference_sets, ref_data, ds_data, relevant_peptides)
        result_qry = reference_sets.insert(-1, comp_set)
      end #if
      peptides = Observation.select(:peptide_sequence, :dataset_name, :dominance).where(:peptide_sequence => relevant_peptides, :dataset_name => result_qry)

    return peptides 
    
    end #comparative_search
    
    def ds_only_search(sets_to_test, reference, dataset, relevant_peptides)
      pep_included = false
      dataset.each do |peptide|
        reference.each do |ref_peptide|
          if (peptide[:peptide_sequence] == ref_peptide[:peptide_sequence])
            pep_included = true 
            break
          end #if
        end #ref_peptide
        if !pep_included
          relevant_peptides.insert(-1, peptide[:peptide_sequence])
        end #if
        pep_included = false
      end #peptide
    end #ds_only_search
    
    def ds_and_ref_search(sets_to_test, reference, dataset, relevant_peptides)
      refs_with_pep = Array.new
      pep_included = false
      dataset.each do |peptide|
        sets_to_test.each do |ref_ds|
          section = reference.where(:dataset_name => ref_ds)
          section.each do |ref_peptide|
            if (peptide[:peptide_sequence] == ref_peptide[:peptide_sequence])
              refs_with_pep.insert(-1, ref_ds)
              pep_included = true 
              break
            end #if
          end #ref_peptide
          if pep_included
            next           
          end #if
        end #ref_ds
      if sets_to_test.size == refs_with_pep.size
        relevant_peptides.insert(-1, peptide[:peptide_sequence])
      end #if
      pep_included = false
      refs_with_pep.clear
      end #peptide
    end #end ds_and_ref_search

  end #comparative_search
  helpers ComparativeSearch
end #Sinatra
