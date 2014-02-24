require 'sinatra/base'

module Sinatra
  module ColumnFinder 
    def find_id_column(table)
      case table
      when "libraries"
        :library_name
      when "selections"
        :selection_name
      when "sequencing_datasets"
        :dataset_name
      when "clusters"
        :dataset_name
      when "results"
        :result_id
      when  "targets"
        :target_id
      when "motif_lists"
        :list_name
      when "peptide_performances"
        :library_name
      end
    end 

  end #module
  helpers ColumnFinder
end #module
