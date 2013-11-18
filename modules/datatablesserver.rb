require 'sinatra/base'
# this module implements the server-side datatables processing
# allows multiple column sorting, individual column filtering
# inspired by http://datatables.net/development/server-side/ruby_mysql
# further information on server-side processing: http://datatables.net/usage/server-side
module Sinatra
  module DataTablesServer 
    
    class DataTablesData

      def initialize(params, referer)
        @referer = referer
        @json_result = {}
        @total_disp_rec = 0 
        @placeholder_args = []
        @params = params
        @columns = get_columns      
        @indexcolumn = :peptide_sequence
        @table = :peptides_sequencing_datasets

        unless @referer.include?("property-search")
          @dataset = params['selElem'].split(",")
          @placeholder_args.insert(-1, *@columns, @table, *@dataset)
          @select = build_select_string
          @total_rec = Observation.where(:dataset_name => @dataset).count
          @where = build_where_string
          qry_string = "" << @select << @where 
        else
          query = DB[:propqry].select(:qry_string, :placeholder).where(:qry_id => params[:selElem].to_i).first
          ph_array = query[:placeholder].split(",")
          @placeholder_args.insert(-1, *ph_array)
          # following queries probably need some optimization...
          #@select = "SELECT `peptides`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides` INNER JOIN `peptides_sequencing_datasets` ON (`peptides_sequencing_datasets`.`peptide_sequence` = `peptides`.`peptide_sequence`) INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) INNER JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) INNER JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s  
          #@select = "SELECT `peptides`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides` INNER JOIN `peptides_sequencing_datasets` ON (`peptides_sequencing_datasets`.`peptide_sequence` = `peptides`.`peptide_sequence`) INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) LEFT JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) LEFT JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s  
          @select = "SELECT `peptides_sequencing_datasets`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides_sequencing_datasets` INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) LEFT JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) LEFT JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s  
          qry_string = "SELECT `peptides_sequencing_datasets`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides_sequencing_datasets` INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) LEFT JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) LEFT JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s  
          #qry_string = "SELECT `peptides`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides` INNER JOIN `peptides_sequencing_datasets` ON (`peptides_sequencing_datasets`.`peptide_sequence` = `peptides`.`peptide_sequence`) INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) LEFT JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) LEFT JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s  
          #qry_string = "SELECT `peptides`.`peptide_sequence`, `sequencing_datasets`.`dataset_name` AS 'dataset', `rank`, `reads`, `dominance` FROM `peptides` INNER JOIN `peptides_sequencing_datasets` ON (`peptides_sequencing_datasets`.`peptide_sequence` = `peptides`.`peptide_sequence`) INNER JOIN `sequencing_datasets` ON (`sequencing_datasets`.`dataset_name` = `peptides_sequencing_datasets`.`dataset_name`) INNER JOIN `selections` ON (`selections`.`selection_name` = `sequencing_datasets`.`selection_name`) INNER JOIN `libraries` ON (`sequencing_datasets`.`library_name` = `libraries`.`library_name`) LEFT JOIN `results` ON (`peptides_sequencing_datasets`.`result_id` = `results`.`result_id`) INNER JOIN `targets` AS 'sel_target' ON (`selections`.`target_id` = `sel_target`.`target_id`) INNER JOIN `targets` AS 'seq_target' ON (`sequencing_datasets`.`target_id` = `seq_target`.`target_id`) WHERE " << query[:qry_string].to_s    
          qry_string.slice!(qry_string.size-6, qry_string.size) if query[:qry_string].empty?
          @select.slice!(@select.size-6, @select.size) if query[:qry_string].empty?
          @total_rec = DB.fetch(qry_string, *@placeholder_args).count
          @where = build_where_string
          qry_string << @where
        end
        # this query (count) can cause extreme query duration (>180 seconds) on some systems
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

      # following methods create the query string for each database query (sorting, filtering, pagination)
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
        @columns= [:peptide_sequence, :dataset,:rank, :reads, :dominance] if @referer.include?("property-search")      
        rows = []
        
        DB.fetch(qry_string, *@placeholder_args) do |row|
          row_array = []
          @columns.each do |cell|
            if cell == :dominance
              formated_dominance = format_dominance(row[cell])
              row_array.insert(-1, formated_dominance)
            else
              row_array.insert(-1, row[cell])
            end
          end #each
          rows.insert(-1, row_array)
        end #each
        rows
      end #get_result
      
      # this module is called for different tables, hence different columns are fetched from db
      def get_columns
        if @referer.include?("datasets")
          [:peptide_sequence, :rank, :reads, :dominance]      
        elsif @referer.include?("systemic-search")
          [:peptide_sequence, :rank, :reads, :dominance, :dataset_name]      
        elsif @referer.include?("property-search")
          [:peptides_sequencing_datasets__peptide_sequence,:rank, :reads, :dominance, :sequencing_datasets__dataset_name]      
        end
      end
      
      def format_dominance(value)
        dom = value * 100
        "%E" % dom
      end
  
    end #end class
    
    def get_datatable_json(params, referer)
        dt_json = DataTablesData.new(params, referer)
        dt_json.json_result
    end

  
  end

  helpers DataTablesServer 
end
