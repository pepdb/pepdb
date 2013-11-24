#encoding=utf-8
require 'sinatra/base'
# this module adds some convenience methods

module Sinatra
  module Utilities
    include Rack::Utils
    alias_method :h, :escape_html
    
    # formats domanice in datatables
    def format_dominance(value)
        dom = value * 100
        "%E" % dom
    end

    def format_spec_score(value)
        "%E" % value 
    end
    
    def is_dominance?(column)
      column == :dominance || column == :dominance_sum
    end

    # align numerical values right 
    def align_right?(column)
      numeric_columns = [:date, :insert_length, :distinct_peptides, :peptide_diversity, :selection_round, :sequence_length, :reads_sum, :dominance_sum, :rank, :reads, :dominance]
      numeric_columns.include?(column)
    end
  
    def choose_data(params)
      if params['selector'] == "sel"
        datatype = Selection.select(:selection_name).where(:library_name => params['checkedElem'])
        columnname = :selection_name
      elsif params['selector'] == "ds"
        datatype = SequencingDataset.select(:dataset_name).where(:selection_name => params['checkedElem'])
        columnname = :dataset_name
      end

      return datatype, columnname
    end #choose_data
    
    # nbsp = non-breaking space, tests if a value other than the blank field
    # in a dropdown-menu was selected
    def not_just_nbsp?(field)
      field != "" && field.match(/^[[:space:]]+$/) == nil
    end

    def option_selected?(field)
      !field.nil? && not_just_nbsp?(field)
    end
  
    # return all libraries, selecions and sequencing datasets that the current user is allowed
    # to access
    def get_allowed_lib_sel_ds(user)
      allowed_lib = []
      allowed_sel = []
      allowed_ds = []
      DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => user.id).each {|ds| allowed_ds.insert(-1, ds[:dataset_name])}
      DB[:libraries_sequel_users].select(:library_name).where(:id => user.id).each {|ds| allowed_lib.insert(-1, ds[:library_name])}
      DB[:selections_sequel_users].select(:selection_name).where(:id => user.id).each {|ds| allowed_sel.insert(-1, ds[:selection_name])}
      libraries = Library.where(:library_name => allowed_lib)
      selections = Selection.where(:selection_name => allowed_sel)
      datasets = SequencingDataset.where(:dataset_name => allowed_ds)
      
      return libraries, selections, datasets
    end
    
    def calc_gen_spec(spec, ref_specs)
      ref_specs.inject(1){|gen_spec, pep_dom| gen_spec * (spec/pep_dom) }   
    end

  end #module

  helpers Utilities
end #module
