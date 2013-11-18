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
        DB[@table].where(@id_column => @row_id).delete
      end
      
      private
      def set_column
        case @table
        when :libraries
          @id_column = :library_name
        when :selections
          @id_column = :selection_name
        when :sequencing_datasets
          @id_column = :dataset_name
        when :results
          @id_column = :result_id
        when :targets
          @id_column = :target_id
        when :clusters
          @id_column = :cluster_id
        when :motif_lists
          @id_column = :list_name
        end
      end #set_column
    end #class

    # this method is called from within routes to delete the given column
    def delete_entry(params)
      dd = DBDeleter.new(params)
      dd.delete
    end

  end #module

  helpers DBDelete 
end #module
