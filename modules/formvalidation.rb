require 'sinatra/base'
# this module offers some basic formvaldition
# e.g. test if given date if formatted correctly
module Sinatra
  module FormValidation

    class FormValidator
      def initialize(params)
          @errors = {}
          @dataset = []
          @params = params
          @datatype = params[:submittype]
          
      end # initialize

      def validate_form
          if @datatype == "library"
            validate_library
          elsif @datatype == "selection"
            validate_selection
          elsif @datatype == "dataset"
            validate_dataset
          elsif @datatype == "cluster"
            validate_cluster
          elsif @datatype == "result"
            validate_result
          elsif @datatype == "target"
            validate_target
          elsif @datatype == "motif"
            validate_motif
          elsif @datatype == "performance"
            validate_performance
          end
          @errors
      end #validate_form
      
      private

      def validate_library
        if given? @params[:libname] 
          if @params[:date].empty?
            @params[:date] = "1970-01-01"
          end
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" unless valid_date_format? @params[:date]
          @errors[:diversity] = "Peptide diversity not a valid floating point number. Use . as decimal delimiter" if !@params[:diversity].empty? && !valid_floating_point?(@params[:diversity])
          @errors[:insert] = "Insert length invalid number" if !@params[:insert].empty? && !valid_number?(@params[:insert]) 
          @params[:enc] = @params[:fbenc] unless given? @params[:enc]
          @params[:ca] = @params[:fbca] unless given? @params[:ca]
          @params[:prod] = @params[:fbprod] unless given? @params[:prod]
        else
          @errors[:libname] = "Field name is required"
        end
      end #valid_lib

      def validate_selection
        if given? @params[:selname] 
          if @params[:date].empty?
            @params[:date] = "1970-01-01"
          end
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" unless valid_date_format? @params[:date]
          @errors[:dlibname] = "Field library is required" unless given? @params[:dlibname]
          @params[:perf] = @params[:fbperf] unless given? @params[:perf]
        else
          @errors[:selname] = "Field name is required"
        end
      end #valid_sel
        
      def validate_dataset
        if given? @params[:dsname] 
          if @params[:date].empty?
            @params[:date] = "1970-01-01"
          end
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" unless valid_date_format? @params[:date]
          @errors[:dselname] = "Field selection is required" unless given? @params[:dselname]
          if !@params[:pepfile].nil?
            @errors[:filetype] = "Given peptide file must be plain text" unless valid_file_format? @params[:pepfile]
          elsif !@params[:statfile].nil?
            @errors[:filetype] = "Given statistics file must be plain text" unless valid_file_format? @params[:statfile]
          elsif @params[:tab].nil?
            @errors[:pepfile] = "No sequence file given" 
          end
          @errors[:seql] = "Sequence length invalid number" if !@params[:seql].empty? && !valid_number?(@params[:seql]) 
          @errors[:selr] = "Selection round invalid number" if !@params[:selr].empty? && !valid_number?(@params[:selr]) 
          @params[:rt] = @params[:fbrt] unless given? @params[:rt]
          @params[:ui] = @params[:fbui] unless given? @params[:ui]
          @params[:or] = @params[:fbor] unless given? @params[:or]
          @params[:prod] = @params[:fbprod] unless given? @params[:prod]
          @params[:seq] = @params[:fbseq] unless given? @params[:seq]
          @params[:selr] = @params[:fbselr] unless given? @params[:selr]
          @params[:seql] = @params[:fbseql] unless given? @params[:seql]
        else
          @errors[:dsname] = "Field name is required"
        end
      end #valid_dataset

      def validate_performance
        if given? @params[:dlibname]
          @erros[:peptide_sequence] = "Field peptide sequence is required" unless given? @params[:pseq]
          @params[:pseq] = @params[:pseq].to_s.upcase
          pep_cnt = Observation.select(:peptide_sequence).join(SequencingDataset, :dataset_name => :dataset_name).where(:library_name => @params[:dlibname].to_s, :peptide_sequence => @params[:pseq].to_s).count
          @errors[:peplib] = "Given peptide #{@params[:pseq]} not found in library #{@params[:dlibname]}" if pep_cnt == 0
        else
          @errors[:dlibname] = "Field library is required"
        end
      end 
        
      def validate_cluster
        if given? @params[:ddsname]
          if !@params[:clfile].nil? 
            @errors[:filetype] = "Given file type must be plain text" unless valid_file_format? @params[:clfile]
          elsif @params[:tab].nil?
            @errors[:clfile] = "No clustering file given" 
          end
        else
          @errors[:ddsname] = "Field sequencing dataset is required"
        end
      end #valid_cluster

      def validate_target
          @params[:sp] = @params[:fbsp] unless given? @params[:sp]
          @params[:tis] = @params[:fbtis] unless given? @params[:tis]
          @params[:cell] = @params[:fbcell] unless given? @params[:cell]
      end #valid_target

      def validate_motif
        if given? @params[:mlname] 
          if !@params[:motfile].nil?
            #@errors[:filetype] = "Given file type must be csv" unless valid_file_format? @params[:motfile]
          elsif @params[:tab].nil?
            @errors[:motfile] = "No motifs file given" 
          end
        else
          @errors[:mlname] = "Field name is required"
        end
      end #valid_motif_

      def valid_file_format?(file)
        if @params[:submittype] != "motif" && file[:type] == "text/plain"
          true
        elsif @params[:submittype] == "motif" && file[:type] == "text/csv" 
          true
        else
          false
        end
        
      end

      def valid_date_format?(date)
        begin
          if date.count('-') != 2
            return false
          end
          @params[:date] = Date.iso8601(date).to_s
          true
        rescue
          false
        end
      end #valid_date?

      def valid_floating_point?(number)
        if /^\d+\.\d+[^\D]*$/.match(number).nil? then false else true end
      end

      def valid_number?(number)
        if /^\d+$/.match(number).nil? then false else true end
      end
      
      def given? field
        !field.empty?
      end
      
    end #class
      
    def validate(params)
      f = FormValidator.new(params)  
      errors = f.validate_form
    end #validate

  end

  helpers FormValidation
end
