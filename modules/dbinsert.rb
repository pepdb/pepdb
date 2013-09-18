require 'sinatra/base'
require 'sqlite3'
require './modules/utilities'

module Sinatra
  module DBInserter 
    class InsertData   
      def initialize(values)
        @values = values
        @errors ={}
        @datatype = values[:submittype]
      end # init
      
      def try_insert
          if @datatype == "library"
            into_library
          elsif @datatype == "selection"
            into_selection
          elsif @datatype == "dataset"
            init_dataset 
          elsif @datatype == "cluster"
            into_cluster 
          elsif @datatype == "result"
            into_result 
          elsif @datatype == "target"
            into_target
          elsif @datatype == "motif"
            into_motif
          end
          @errors
      end #try_insert

      def into_library
        begin
          DB[:libraries].insert(:library_name => "#{ h @values[:libname].to_s}", :encoding_scheme =>"#{ h @values[:encodings].to_s}", :carrier => "#{h @values[:carrier].to_s}", :produced_by => @values[:prod].to_s, :date => @values[:date], :insert_length => @values[:insert].to_i, :peptide_diversity => @values[:diversity].to_f)
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:lib] = "Given name not unique"
          else
           @errors[:lib] = "database error" 
          end
        end
      end #library

      def into_selection
        begin
          DB[:selection].insert(:selection_name => @values)
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:lib] = "Given name not unique"
          else
           @errors[:lib] = "database error" 
          end
        end
      end #library
      
      
    end #class  
      
    def insert_data(values)
      d = InsertData.new(values)  
      errors = d.try_insert
    end #validate

  end

  helpers DBInserter 
end
