require 'sinatra/base'

module Sinatra
  module DataTablesServer 
    
    class DataTablesData

      def initialize(params, referer)
        @referer = referer
        @json_result = {}
        @total_disp_rec = 0 
        @placeholder_args = []
        @params = params
        @dataset = params['selElem'].split(",")
        @columns = get_columns      
        @indexcolumn = :peptide_sequence
        @table = :peptides_sequencing_datasets
        @placeholder_args.insert(-1, *@columns, @table, *@dataset)
        @select = build_select_string
        @total_rec = Observation.where(:dataset_name => @dataset).count
        @where = build_where_string
        qry_string = "" << @select << @where 
        @total_disp_rec = DB.fetch(qry_string, *@placeholder_args).count
        @order = build_order_string
        
        @limit = build_limit_string
        @result_array = get_result
        @secho = params[:sEcho].to_i      
      end #initialize

      def json_result
        @json_result[:iTotalRecords] = @total_rec
        @json_result[:iTotalDisplayRecords] = @total_disp_rec
        @json_result[:aaData] = @result_array

        @json_result.to_json
      end #json_result
        
      private

      def build_select_string
        select = "SELECT "
        (0...@columns.size).each do |index|
          select << "?, "
        end
        select.chop!.chop!
        select << " FROM ? WHERE dataset_name IN ("
        (0...@dataset.size).each do |index|
          select << "?, "
        end
        select.chop.chop << ") "
      end

      def build_order_string
        order = ""
        if @params[:iSortCol_0] != "" && @params[:iSortingCols].to_i > 0
          order = "ORDER BY "
          (0...@params[:iSortingCols].to_i).each do |index|
            order << "? #{@params['sSortDir_' + index.to_s]} , "
            @placeholder_args.insert(-1, @columns[@params['iSortCol_' + index.to_s].to_i])
          end
        end
        order.chop.chop
      end

      def build_limit_string 
        limit = ""
        if @params[:iDisplayStart] != "" && @params[:iDisplayLength] != -1
          limit = "LIMIT ?, ?"
          @placeholder_args.insert(-1, @params[:iDisplayStart], @params[:iDisplayLength])
        end #if 
        limit
      end #build_limit_string

      def build_where_string
        filter =""
        (0...@columns.size).each do |column|
          if @params['bSearchable_' + column.to_s] == "true" && @params['sSearch_' + column.to_s] != ""
            filter << " AND ? LIKE ?"
            @placeholder_args.insert(-1, @columns[column], "%"+@params['sSearch_' + column.to_s].to_s.upcase+"%")
          end #if
        end #each 
        filter 
      end #build_where_string
        
      def get_result
        qry_string = "" << @select << @where << @order << @limit 
        rows = []
        DB.fetch(qry_string, *@placeholder_args) do |row|
          row_array = []
          @columns.each do |cell|
            row_array.insert(-1, row[cell])
          end #each
          rows.insert(-1, row_array)
        end #each
        rows
      end #get_result
      
      def get_columns
        if @referer.include?("datasets")
          [:peptide_sequence, :rank, :reads, :dominance]      
        elsif @referer.include?("systemic-search")
          [:peptide_sequence, :dataset_name,:rank, :reads, :dominance]      
        end
      end
  
    end #end class
    
    def get_datatable_json(params, referer)
        dt_json = DataTablesData.new(params, referer)
        dt_json.json_result
    end

  
  end

  helpers DataTablesServer 
end
