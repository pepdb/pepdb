require 'sinatra/base'

module Sinatra
  module Utilities
    include Rack::Utils
    alias_method :h, :escape_html

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
    
    def not_just_nbsp?(field)
      field.codepoints.to_a.size > 1
    end

    def option_selected?(field)
      !field.nil? && not_just_nbsp?(field)
    end
  
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

  end #module

  helpers Utilities
end #module
