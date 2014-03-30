require 'sinatra/base'
# this module handles database column deletions 
module Sinatra
  module DBDelete 
    class DBDeleter
      def initialize(params)
        @table = params[:table].to_sym
        @id_column
        @row_id = params[:id].to_s
        set_column
      end #init

      def delete 
        if @table == :peptide_performances
          ids = @row_id.split(',', 2)
          DB[@table].where(@id_column => ids[0], @id_column2 => ids[1]).delete
        else
          DB[@table].where(@id_column => @row_id).delete
        end
      end
      
      private
      def set_column
        case @table
        when :libraries
          @id_column = :library_name
        when :selections
          @id_column = :selection_name
          #TODO add library distinct peptide update
        when :sequencing_datasets
          @id_column = :dataset_name
          #TODO add library distinct peptide update
        when :results
          @id_column = :result_id
        when :targets
          @id_column = :target_id
        when :clusters
          @id_column = :cluster_id
        when :motif_lists
          @id_column = :list_name
        when :peptide_performances
          @id_column = :peptide_sequence
          @id_column2 = :library_name
        end
      end #set_column
    end #class

    # this method is called from within routes to delete the given row 
    def delete_entry(params)
      dd = DBDeleter.new(params)
      dd.delete
    end

  end #module

  helpers DBDelete 
end #module
