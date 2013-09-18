require 'sinatra/base'

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
          end
          @errors
      end #validate_form
      
      private

      def validate_library
        if given? @params[:libname] 
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" if !@params[:date].empty? && !valid_date_format?(@params[:date])
          @errors[:diversity] = "Peptide diversity not a valid floating point number. Use . as decimal delimiter" if !@params[:diversity].empty? && !valid_floating_point?(@params[:diversity])
          @errors[:insert] = "Insert length invalid number" if !@params[:insert].empty? && !valid_number?(@params[:insert]) 
        else
          @errors[:libname] = "Field name is required"
        end
      end #valid_lib

      def validate_selection
        if given? @params[:selname] 
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" if !@params[:date].empty? && !valid_date_format?(@params[:date])
          @errors[:dlibname] = "Field library is required" unless given? @params[:dlibname]
        else
          @errors[:selname] = "Field name is required"
        end
      end #valid_sel
        
      def validate_dataset
        if given? @params[:dsname] 
          @errors[:date] = "Date format not valid, must be yyyy-mm-dd" if !@params[:date].empty? && !valid_date_format?(@params[:date])
          @errors[:dselname] = "Field selection is required" unless given? @params[:dselname]
          @errors[:seql] = "Sequence length invalid number" if !@params[:seql].empty? && !valid_number?(@params[:seql]) 
          @errors[:selround] = "Selection round invalid number" if !@params[:selround].empty? && !valid_number?(@params[:selround]) 
        else
          @errors[:dsname] = "Field name is required"
        end
      end #valid_dataset
        
      def validate_cluster
        if given? @params[:ddsname] 
        else
          @errors[:ddsname] = "Field sequencing dataset is required"
        end
      end #valid_cluster

      def validate_target
      end #valid_target

      def validate_result
        if given? @params[:ddsname] 
          @errors[:peptide] = "Field peptide sequence is required" unless given? @params[:peptide]
        else
          @errors[:ddsname] = "Field sequencing dataset is required"
        end
      end #valid_result

      def validate_motif
        if given? @params[:mlname] 
        else
          @errors[:mlname] = "Field name is required"
        end
      end #valid_result



      def valid_date_format?(date)
        begin
          Date.iso8601(date)
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
